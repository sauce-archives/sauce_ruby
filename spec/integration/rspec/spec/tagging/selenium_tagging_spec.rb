require "spec_helper"
require "sauce"
require "sauce/connect"

Sauce.config do |c|
  c.browsers = [
      ["Windows 2008", "iexplore", "9"],
      ["Linux", "opera", 12]
  ]
  c[:application_host] = "localhost"
end

describe "Specs with the @sauce tag", :sauce => true do

  before :all do
    $TAGGED_EXECUTIONS = 0
  end

  after :all do
    $TAGGED_EXECUTIONS.should eq 2
  end

  it "should get run on every defined browser" do
    $TAGGED_EXECUTIONS += 1
  end

  it "should be using Sauce Connect" do
    Sauce::Utilities::Connect.instance_variable_get(:@tunnel).should_not be_nil
  end
end

describe "Specs without the @sauce tag" do
  before :all do
    $UNTAGGED_EXECUTIONS = 0
  end

  after :all do
    $UNTAGGED_EXECUTIONS.should eq 1
  end

  it "should only run once" do
    $UNTAGGED_EXECUTIONS += 1
  end
end