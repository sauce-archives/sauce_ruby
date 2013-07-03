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

describe "Specs in the Selenium Directory" do
  it_behaves_like "an integrated spec"
end

describe "Specs in the Selenium Directory with the sauce tag", :sauce => true do
  it_behaves_like "an integrated spec"
end