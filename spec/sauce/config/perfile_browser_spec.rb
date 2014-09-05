require "spec_helper"

describe "Sauce::Config" do
  describe "#perfile_browsers" do
    before :each do
      ENV['SAUCE_PERFILE_BROWSERS'] = nil
    end

    after :each do
      ENV['SAUCE_PERFILE_BROWSERS'] = nil
    end

    it "returns browsers when perfile_browsers is blank" do
      expected_browsers = [
        ["Linux", "Chrome", "nil"]
      ]

      Sauce.config do |c|
        c[:browsers] = expected_browsers
      end

      config = Sauce::Config.new

      filename = "./features/duckduck.feature"
      fn = 14

      Sauce::Config.new.caps_for_location(filename, fn).should eq expected_browsers
    end

    it "should return the browsers for the requested location" do
      expected_browsers = [
        ["Linux", "Chrome", "nil", {}],
        ["Mac", "Safari", "5", {}]
      ]

      browser_hash = expected_browsers.map { |a| 
       {"os" => a[0], "browser" => a[1], "version" => a[2], "caps" => a[3]}
      }

      env_hash = {
        "./features/duckduck.feature:14"=> browser_hash,
        "./features/adifferent.feature"=>[
          {"os"=>"Windows 7", "browser"=>"Firefox", "version"=>"19"}
        ]
      }

      ENV['SAUCE_PERFILE_BROWSERS'] = env_hash.to_json

      filename = "./features/duckduck.feature"
      fn = 14

      Sauce::Config.new.caps_for_location(filename, fn).should eq expected_browsers
    end

    it "returns the line number location if present" do
      expected_browsers = [
        ["Linux", "Chrome", "nil", {}],
        ["Mac", "Safari", "5", {}]
      ]

      browser_hash = expected_browsers.map { |a| 
       {"os" => a[0], "browser" => a[1], "version" => a[2]}
      }

      env_hash = {
        "./features/duckduck.feature"=>[
          {"os"=>"Windows 7", "browser"=>"Firefox", "version"=>"19"}
        ],
        "./features/duckduck.feature:11"=> browser_hash
      }

      ENV['SAUCE_PERFILE_BROWSERS'] = env_hash.to_json

      filename = "./features/duckduck.feature"
      fn = 11

      Sauce::Config.new.caps_for_location(filename, fn).should eq expected_browsers
    end

    it "ignores line number if it can't find it" do
      expected_browsers = [
        ["Linux", "Chrome", "nil", {}],
        ["Mac", "Safari", "5", {}]
      ]

      browser_hash = expected_browsers.map { |a| 
       {"os" => a[0], "browser" => a[1], "version" => a[2]}
      }

      env_hash = {
        "./features/duckduck.feature:11"=>[
          {"os"=>"Windows 7", "browser"=>"Firefox", "version"=>"19"}
        ],
        "./features/duckduck.feature"=> browser_hash
      }

      ENV['SAUCE_PERFILE_BROWSERS'] = env_hash.to_json

      filename = "./features/duckduck.feature"
      fn = 6

      Sauce::Config.new.caps_for_location(filename, fn).should eq expected_browsers
    end
  end
end