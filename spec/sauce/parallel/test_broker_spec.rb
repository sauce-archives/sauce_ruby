require "json"
require "rspec"
require "sauce/parallel/test_broker"

describe Sauce::TestBroker do

  describe "#next_environment" do

    before :all do
      Sauce.config do |c|
        c.browsers = [
            ["Windows 7", "Opera", "10"],
            ["Linux", "Firefox", "19"]
        ]
      end
    end

    it "returns the first environment for new entries" do
      first_environment = Sauce::TestBroker.next_environment ["spec/a_spec"]
      first_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => ("'" +
                                    JSON.generate({"os" => "'Windows 7'",
                                                    "browser" => "'Opera'",
                                                    "version" => "'10'"}) +
                                    "'")
      })
    end

    it "should only return an environment once" do
      Sauce::TestBroker.next_environment "spec/b_spec"
      second_environment = Sauce::TestBroker.next_environment ["spec/a_spec"]

      second_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => ("'" +
                                    JSON.generate({"os" => "'Linux'",
                                                    "browser" => "'Firefox'",
                                                    "version" => "'19'"}) +
                                    "'")
      })
    end
  end

  describe "#test_platforms" do
    it "should report the same groups as configured in Sauce.config" do
      Sauce::TestBroker.test_platforms.should eq Sauce.get_config.browsers
    end
  end
end
