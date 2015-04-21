require "spec_helper"

describe Sauce::Utilities::Rake do

  describe "#create_sauce_helper" do
    context "with Capybara" do
      before :all do
        Object.stub(:const_defined?).with("Capybara").and_return true
      end

      it "includes the browser block" do
        Sauce::Utilities::Rake.sauce_helper.should include browser_block
      end

      it "includes the require for sauce" do
        Sauce::Utilities::Rake.sauce_helper.should include "require \"sauce\""
      end

      it "does not include Capybara" do
        Sauce::Utilities::Rake.sauce_helper.should include "require \"sauce/capybara\""
      end
    end

    context "without Capybara" do
      before :all do
        Object.stub(:const_defined?).with("Capybara").and_return false
      end

      it "includes the require for sauce/capybara" do
        Sauce::Utilities::Rake.sauce_helper.should_not include "require \"sauce/capybara\""
      end
    end
  end

  def browser_block
    return <<-ENDFILE
Sauce.config do |config|
  config[:browsers] = [
    ["OS", "BROWSER", "VERSION"],
    ["OS", "BROWSER", "VERSION"]
  ]
  config[:sauce_connect_4_executable] = # path to Sauce Connect 4 executable
end
    ENDFILE
  end
end
