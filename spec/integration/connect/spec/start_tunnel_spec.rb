require "spec_helper"

describe "Sauce::Config" do
  it "should start Connect when start_tunnel is set" do
    Sauce::RSpec::SeleniumExampleGroup.class_variable_defined?(:@@tunnel).should be_true
  end
end