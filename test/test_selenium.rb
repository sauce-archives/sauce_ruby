require File.expand_path("../helper", __FILE__)

class TestSelenium < Test::Unit::TestCase
  def test_successful_connection_from_environment
    selenium = Sauce::Selenium.new(:job_name => "Sauce gem test suite: test_selenium.rb",
                                   :browser_url => "http://www.google.com/")
    selenium.start
    selenium.open "/"
    selenium.stop
  end

  def test_passed
    selenium = Sauce::Selenium.new(:job_name => "This test should be marked as passed",
                                   :browser_url => "http://www.google.com/")
    selenium.start
    job_id = selenium.session_id
    begin
      selenium.passed!
    ensure
      selenium.stop
    end

    job = Sauce::Job.find(job_id)
    while job.status == "in progress"
      sleep 0.5
      job.refresh!
    end

    assert job.passed, job
  end

  def test_failed
    selenium = Sauce::Selenium.new(:job_name => "This test should be marked as failed",
                                   :browser_url => "http://www.google.com/")
    selenium.start
    job_id = selenium.session_id
    begin
      selenium.failed!
    ensure
      selenium.stop
    end

    job = Sauce::Job.find(job_id)
    while job.status == "in progress"
      sleep 0.5
      job.refresh!
    end
    assert !job.passed, job
  end
end
