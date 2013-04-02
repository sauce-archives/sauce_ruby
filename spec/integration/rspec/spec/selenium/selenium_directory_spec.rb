require "spec_helper"
require "sauce"

Sauce.config do |c|
  c.browsers = [
      ["Windows 2008", "iexplore", "9"],
      ["Linux", "opera", 12]
  ]
end

describe "Specs in the Selenium Directory" do

  before :all do
    $EXECUTIONS = 0
  end

  after :all do
    $EXECUTIONS.should be 2
  end

  it "should get run on every defined browser" do
    $EXECUTIONS += 1
  end
end