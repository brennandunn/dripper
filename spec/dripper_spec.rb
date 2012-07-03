require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dripper" do
  subject { Class.new { include Dripper } }
  let!(:now) { Time.now }
  let(:instance) { stub(id: 1, created_at: now) }

  it 'requires an id and timestamp' do
    expect { subject.new(stub()) }.to raise_error(ArgumentError)
    expect { subject.new(instance) }.to_not raise_error
  end

  describe 'choosing a time to schedule events' do

    it 'uses the timestamp plus the after amount when send_at is not defined' do
      subject.after(1.day) {}

      drip = subject.new(instance)
      drip.scheduled_times.should == [now + 1.day]
    end

    describe 'generating a schedule' do
      it 'ignores send_at when the after amount is less than a day' do
        subject.send_at [9, 0]
        subject.after(5.minutes) {}

        drip = subject.new(instance)
        drip.scheduled_times.should == [now + 5.minutes]
      end

      it 'schedules for the number of days out plus the send_at offset' do
        subject.send_at [9, 0]
        subject.after(2.days) {}

        drip = subject.new(instance)
        drip.scheduled_times.should == [(now + 2.days).beginning_of_day + 9.hours]
      end

      describe 'when skipping weekends' do
        before do
          subject.send_at [9, 0], weekends: false
        end

        it 'sends on a Friday for Saturday events' do
          subject.after(5.days) {}
          instance.should_receive(:created_at).and_return { Time.now.beginning_of_week } # Monday

          drip = subject.new(instance)
          drip.scheduled_times.should == [(instance.created_at + 4.days).beginning_of_day + 9.hours] # Friday, 9am
        end
        it 'sends on a Monday for Sunday events' do
          subject.after(6.days) {}
          instance.should_receive(:created_at).and_return { Time.now.beginning_of_week } # Monday

          drip = subject.new(instance)
          drip.scheduled_times.should == [(instance.created_at + 7.days).beginning_of_day + 9.hours] # Monday, 9am

        end
      end
    end

  end

  describe 'performing an offset action' do
    let(:drip) { subject.new(instance) }

    before do
      subject.after 1.day do |instance|
        instance.foo
      end
    end

    it 'gracefully fails when an after block cannot be found' do
      expect { subject.perform position: 4, id: 1 }.to_not raise_error
    end

    it 'calls the block and supplies the instance' do
      instance.should_receive :foo
      subject.should_receive(:fetch_instance).and_return(instance)
      subject.perform position: 0, id: 1
    end
  end

  describe 'Using with resque-scheduler' do
    subject { Class.new { include Dripper::ResqueScheduler } }
    before { class Resque ; end }

    it 'attempts to enqueue each job' do
      subject.after(1.day) {}
      drip = subject.new(instance)
      offset = drip.scheduled_times.first
      Resque.should_receive(:enqueue_at).with(offset, subject, { id: instance.id })

      drip.schedule!
    end

    it 'purges any scheduled jobs' do
      Resque.should_receive(:remove_delayed).with(subject, { id: instance.id })

      drip = subject.new(instance)
      drip.clear!
    end

  end

end
