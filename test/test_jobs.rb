require 'helper'
require 'json'

class TestSauce < Test::Unit::TestCase
  context "A jobs instance" do
    setup do
      # Create this file and put in your details to run the tests
      account = YAML.load_file "live_account.yml"
      @username = account["username"]
      @access_key = account["access_key"]
      @ip = account["ip"]
      @client = Sauce::Client.new(:username => @username,
                                  :access_key => @access_key)
    end    

    should "initialize with passed variables" do
      job_json = JSON.parse '{"BrowserVersion": "3.", "Name": "example_job/name.rb", "_rev": "5-228269313", "CreationTime": 1266698090, "AssignmentTime": 1266698097, "Server": "192.168.0.1:4443", "AssignedTo": "f663372ba04444ce8cb3e6f61503f304", "ChefStartTime": 1266698101, "EndTime": 1266698139, "Type": "job", "Interactive": "true", "Status": "complete", "SeleniumServerLogUploadRequest": {"bucket": "sauce-userdata", "key": "sgrove/6337fe576deba0ba278dc1b5dfceac5f/selenium-server.log"}, "Tags": ["tag_1", "tag_2"], "ResultId": "6337fe576deba0ba278dc1b5dfceac5f", "AttachmentRequests": {}, "ModificationTime": 1266698139, "Browser": "firefox", "StartTime": 1266698101, "Owner": "sgrove", "_id": "01fc48caba6d15b46fad79e1b0562bbe", "OS": "Linux", "VideoUploadRequest": {"bucket": "sauce-userdata", "key": "sgrove/6337fe576deba0ba278dc1b5dfceac5f/video.flv"}}'

      client = Sauce::Client.new(:username => "test_user",
                                 :access_key => "abc123")
      
      job = client.jobs.new(job_json)

      assert_equal "sgrove", job.owner
      assert_equal "01fc48caba6d15b46fad79e1b0562bbe", job.id
      assert_equal "example_job/name.rb", job.name 
      assert_equal "5-228269313", job._rev 
      assert_equal "192.168.0.1:4443", job.server
      assert_equal "f663372ba04444ce8cb3e6f61503f304", job.assigned_to 

      assert_equal "job", job.sauce_type
      assert_equal "true", job.interactive
      assert_equal "complete", job.status
      assert_equal ["tag_1", "tag_2"], job.tags
      assert_equal "6337fe576deba0ba278dc1b5dfceac5f", job.result_id

      # TODO: Buckets
      #assert_equal , job.selenium_server_log_upload_request 
      #assert_equal , job.attachment_requests 
      #assert_equal , job.videoupload_request

      assert_equal "Linux", job.os
      assert_equal "firefox", job.browser
      assert_equal "3.", job.browser_version

      assert_equal 1266698090, job.creation_time
      assert_equal 1266698097, job.assignment_time
      assert_equal 1266698101, job.chef_start_time
      assert_equal 1266698139, job.end_time 
      assert_equal 1266698139, job.modification_time
      assert_equal 1266698101, job.start_time
    end

    def teardown
      @client.tunnels.destroy
    end
  end
end
