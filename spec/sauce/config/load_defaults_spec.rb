require "spec_helper"

describe "Sauce" do
  before :each do
    Sauce.clear_config
  end

  describe "#get_config" do
    it "returns an empty config by default" do
      Sauce.get_config.opts.should eq Sauce::Config.new(false).opts
    end

    it "Can return default options" do
      Sauce.get_config(:default).opts.should eq Sauce::Config.new().opts
      Sauce.get_config(:default).opts.length.should_not eq 0
    end
  end
end