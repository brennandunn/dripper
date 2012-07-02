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

    describe 'when defining send_at' do
      it 'ignores when the after amount is less than a day' do
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
        it 'sends on a Friday for Saturday events'
        it 'sends on a Monday for Sunday events'
      end
    end

  end

  describe 'generating a schedule' do

  end

end
