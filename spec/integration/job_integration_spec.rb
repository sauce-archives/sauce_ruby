require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sauce::Job do
  context 'with a running Sauce::Selenium client' do
    let(:jobname) { 'this a test, this is only a test' }
    before :each do
      @client = Sauce::Selenium.new(:name => jobname)
      @client.start
      @session_id = @client.session_id
    end

    describe '#find' do
      it 'should fetch the right name from the API' do
        job = Sauce::Job.find(@session_id)
        job.name.should == jobname
      end
    end

    after :each do
      @client.stop
    end
  end
end
