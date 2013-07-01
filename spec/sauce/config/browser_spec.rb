require "spec_helper"

describe "Sauce::Config" do
  describe "#browser" do

    after :all do
      ENV["TEST_ENV_NUMBER"] = nil
    end

    context "when @opts[:browser] is not nil" do
      it "returns @opts[:browser]" do
        Sauce.clear_config

        Sauce.config do |c|
          c[:browser] = "Opera"
        end

        Sauce::Config.new.browser.should eq "Opera"
      end
    end

    context "when @opts[:browser] is nil" do
      context "and this is not parallel test" do
        it "defaults to the first row of :browsers" do
          Sauce.clear_config

          ENV["TEST_ENV_NUMBER"] = nil

          Sauce.config do |c|
            c[:browsers] = [["Windows", "Opera", 10]]
          end

          Sauce::Config.new.browser.should eq "Opera"
        end
      end

      context "and this is *not* a parallel test" do
        it "should return the value set for :browser" do
          ENV["TEST_ENV_NUMBER"] = "2"

          Sauce.clear_config

          expect {
            Sauce::Config.new.browser.should_raise
          }.to raise_exception(StandardError, no_browser_message)
        end
      end
    end
  end
end

def no_browser_message
  <<-MESSAGE
No browser has been configured.

It seems you're trying to run your tests in parallel, but haven't configured your specs/tests to use the Sauce integration.

To fix this, add :sauce => true to your specs or make your tests subclasses of Sauce::TestCase or Sauce::RailsTestCase.

For more details check the gem readme at https://github.com/DylanLacey/sauce_ruby/blob/master/README.markdown
  MESSAGE
end