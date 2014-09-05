require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'sauce/config'

describe "Sauce::Config" do
  describe "#extract_options_from_hash" do
    let(:test_options) {
      {
        "SAUCE_USERNAME" => "user",
        "SAUCE_ACCESS_KEY" => "ac",
        "SAUCE_APPLICATION_HOST" => "application_host"
      }
    }

    let(:test_config) {Sauce::Config.new}

    it "should set any options starting with SAUCE" do
      test_config
      opts = test_config.send(:extract_options_from_hash, test_options)

      opts[:username].should eq "user"
      opts[:application_host].should eq "application_host"
    end

    context "when passed the jenkins authentication parameters" do
      let(:jenkins_options) {
        {
          "SAUCE_USER_NAME" => "jenkins_user",
          "SAUCE_API_KEY" => "jenkins_access_key"
        }
      }

      it "should parse the SAUCE_USER_NAME value" do
        test_config
        opts = test_config.send(:extract_options_from_hash, jenkins_options)

        opts[:username].should eq "jenkins_user"
      end

      it "should parse the SAUCE_USER_NAME value" do
        test_config
        opts = test_config.send(:extract_options_from_hash, jenkins_options)

        opts[:access_key].should eq "jenkins_access_key"
      end
    end

    context "when passed build numbers" do
      it "should accept BUILD_NUMBER" do
        opts = test_config.send(:extract_options_from_hash, {"BUILD_NUMBER" => "build"})
        opts[:build].should eq "build"
      end

      it "should accept TRAVIS_BUILD_NUMBER" do
        opts = test_config.send(:extract_options_from_hash, {"TRAVIS_BUILD_NUMBER" => "build"})
        opts[:build].should eq "build"
      end

      it "should accept CIRCLE_BUILD_NUM" do
        opts = test_config.send(:extract_options_from_hash, {"CIRCLE_BUILD_NUM" => "build"})
        opts[:build].should eq "build"
      end
    end

    context "when passed browsers in a json array keyed to SAUCE_ONDEMAND_BROWSERS" do
      let(:browsers) {
        { "SAUCE_ONDEMAND_BROWSERS" => [
            {:os => "os1", :browser => "ie1", "browser-version" => "version1"},
            {:os => "os2", :browser => "ie2", "browser-version" => "version2"}
          ].to_json,
          "SAUCE_BROWSER" => "not_browser",
          "SAUCE_BROWSER_VERSION" => "not_version",
          "SAUCE_OS" => "not_os"
        }
      }

      it "should extract the browsers" do
        opts = test_config.send(:extract_options_from_hash, browsers)
        opts[:browsers].should eq([
          ["os1", "ie1", "version1"],
          ["os2", "ie2", "version2"]
        ])
      end
    end

    context "when passed browsers in a json array keyed to SAUCE_BROWSERS" do
      let(:browsers) {
        { "SAUCE_BROWSERS" => [
            {:os => "os1", :browser => "ie1", "version" => "version1"},
            {:os => "os2", :browser => "ie2", "version" => "version2"}
        ].to_json,
          "SAUCE_BROWSER" => "not_browser",
          "SAUCE_BROWSER_VERSION" => "not_version",
          "SAUCE_OS" => "not_os"
        }
      }

      it "should extract the browsers" do
        opts = test_config.send(:extract_options_from_hash, browsers)
        opts[:browsers].should eq([
          ["os1", "ie1", "version1", nil],
          ["os2", "ie2", "version2", nil]
        ])
      end
    end
  end
end