require File.expand_path("../helper", __FILE__)

class TestJob < Test::Unit::TestCase
  def test_running_a_job_creates_a_reasonable_job_object
    selenium = Sauce::Selenium.new(:name => "test_running_a_job_creates_a_job_object")
    selenium.start
    session_id = selenium.session_id
    selenium.stop

    job = Sauce::Job.find(session_id)
    assert_equal "test_running_a_job_creates_a_job_object", job.name
  end
end
