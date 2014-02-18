require "spec_helper"

describe "Sauce::Config", :sauce => true do
  it "should have rspec in its tool set", :sauce => true do
    capabilities = Sauce.get_config.to_desired_capabilities
    capabilities[:client_version].should include "Rspec"
  end

  it "should have Capybara in its tool set", :sauce => true do
    capabilities = Sauce.get_config.to_desired_capabilities
    capabilities[:client_version].should include "Capybara"
  end
end
