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

  describe "::Config" do
    describe "#new" do
      before :each do
        Sauce.clear_config
      end

      context "passed a hash and :without_defaults => false" do
        let(:c) { Sauce::Config.new(:myoption => 1337, :without_defaults => false) }
        
        it "uses options from the hash" do
          c[:myoption].should == 1337
        end

        it "defaults other options" do
          c[:host].should equal Sauce::Config::DEFAULT_OPTIONS[:host]
        end
      end

      context "passed a hash and :without_defaults => true" do
        let(:c) { Sauce::Config.new(:myoption => 1337, :without_defaults => true) }
        
        it "uses options from the hash" do
          c[:myoption].should == 1337
        end

        it "does not default other options" do
          c[:host].should be_nil
        end
      end
    end
  end
end