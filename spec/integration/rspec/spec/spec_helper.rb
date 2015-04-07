require "simplecov"

SimpleCov.start do
  SimpleCov.root "#{Dir.pwd}/../../../"
  command_name 'RSpec Integration'
  use_merging true
  merge_timeout 6000
end

require "rspec"
require "sauce"

def page_deprecation_warning
  return <<-MESSAGE
[DEPRECATED] Using the #page method is deprecated for RSpec tests without Capybara.  Please use the #s or #selenium method instead.
If you are using Capybara and are seeing this message, check the Capybara README for information on how to include the Capybara DSL in your tests.
  MESSAGE
end

shared_examples_for "an integrated spec" do

  before :all do
    $TAGGED_EXECUTIONS = 0
  end

  after :all do
    $TAGGED_EXECUTIONS.should eq 2
  end

  context "When calling the #page method" do
    it "should get access to the Webdriver object" do
      page.should be_a_kind_of Sauce::Selenium2
    end

    it "should output a deprecation message" do
      self.should_receive(:warn).with(page_deprecation_warning).and_call_original
      page
    end
  end

  it "should be using Sauce Connect" do
    Sauce::Utilities::Connect.instance_variable_get(:@tunnel).should_not be_nil
  end

  it "should get run on every defined browser" do
    $TAGGED_EXECUTIONS += 1
  end
end

Sauce.config do |c|
  c[:sauce_connect_4_executable] = ENV["SAUCE_CONNECT_4_EXECUTABLE"]
end