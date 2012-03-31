require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sauce::Selenium do
  before :each do
    Sauce.config do |c|
      # Vaporize the config again
    end

    @client = Sauce::Selenium.new(:job_name => 'Sauce gem integration test',
                                  :browser_url => 'http://www.saucelabs.com')
  end

  context 'with a started client' do
    before :each do
      @client.start
    end

    it 'should properly open the page' do
      @client.open '/'
      @client.stop
    end

    it 'should set the job as passed on saucelabs.com' do
      jobid = @client.session_id

      begin
        # Forcefully set the job to passed
        @client.passed!
      ensure
        @client.stop
      end

      job = Sauce::Job.find(jobid)
      while job.status == 'in progress'
        sleep 0.5
        job.refresh!
      end

      job.passed.should be true
    end

    it 'should set the job as failed on saucelabs.com' do
      jobid = @client.session_id

      begin
        # Forcefully set the job to failed
        @client.failed!
      ensure
        @client.stop
      end

      job = Sauce::Job.find(jobid)
      while job.status == 'in progress'
        sleep 0.5
        job.refresh!
      end

      job.passed.should be false
    end
  end
end
