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
      class SendAtNotDefined
        include Dripper

        after 1.day do ; end
      end

      drip = SendAtNotDefined.new(instance)
      drip.scheduled_times.should == [now + 1.day]
    end

    describe 'when defining send_at' do
      it 'ignores when the after amount is less than a day'

      describe 'when skipping weekends' do
        it 'sends on a Friday for Saturday events'
        it 'sends on a Monday for Sunday events'
      end
    end

  end

  describe 'generating a schedule' do

  end

end
