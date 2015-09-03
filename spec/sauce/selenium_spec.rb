require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sauce::Selenium2 do
  describe "itself" do

    before :each do
      mock_driver = double(::Selenium::WebDriver::Driver)
      mock_driver.stub(:file_detector=)
      mock_driver.stub(:session_id)
      ::Selenium::WebDriver.should_receive(:for).and_return(mock_driver)
    end

    describe '#initialize' do
      it 'should work without arguments' do
        client = Sauce::Selenium2.new
        client.should_not be nil
      end

      it 'should pass the job_name argument into the config' do
        expected = 'Dummy Job Name'
        client = Sauce::Selenium2.new(:job_name => expected)
        client.config[:job_name].should == expected
      end
    end


    context 'with an initialized object' do
      before :each do
        @client = Sauce::Selenium2.new
      end

      describe '#stop' do
        it 'should call quit on the driver' do
          @client.driver.should_receive(:quit).and_return(true)
          @client.stop
        end
      end

      describe '#session_id' do
        it 'should query the driver for the session_id' do
          expected = 101
          bridge = double('bridge')
          bridge.should_receive(:session_id).and_return(expected)
          @client.driver.should_receive(:bridge).and_return(bridge)
          @client.session_id.should == expected
        end
      end

      describe '#method_missing' do
        it 'should pass #navigate#to onto the driver' do
          url = 'http://example.com'
          navigator = double('navigator')
          navigator.should_receive(:to).with(url).and_return(true)
          @client.driver.should_receive(:navigate).and_return(navigator)

          @client.navigate.to url
        end
      end
    end
  end
end
