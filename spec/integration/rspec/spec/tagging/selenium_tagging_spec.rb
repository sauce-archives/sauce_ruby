require "spec_helper"
require "sauce"
require "sauce/connect"

Sauce.config do |c|
  c:[browsers] = [
      ["Windows 2008", "iexplore", "9"],
      ["Linux", "opera", 12]
  ]
  c[:application_host] = "localhost"
end

describe "Specs with the @sauce tag", :sauce => true do
  it_behaves_like "an integrated spec"
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