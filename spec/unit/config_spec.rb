require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sauce::Config do
  let(:c) { Sauce::Config.new }

  describe '#[]' do
    it "should return nil for options that don't exist" do
      c = Sauce::Config.new
      c[:undefined].should be_nil
    end

    it "should return defaults if they haven't been set" do
      c = Sauce::Config.new
      c[:browser].should == Sauce::Config::DEFAULT_OPTIONS[:browser]
    end

    it "should return the value set in the constructor" do
      c = Sauce::Config.new(:myoption => 1337)
      c[:myoption].should == 1337
    end
  end

  describe "#[]=" do
    it "should allow setting arbitrary options" do
      c[:setting_option] = 1337
      c[:setting_option].should == 1337
    end

    it "should allow using strings for keys" do
      c["my-option"] = 1337
      c["my-option"].should == 1337
    end
  end

  describe 'deprecate method_missing' do
    it 'should warn when accessing an old style method' do
      c.should_receive(:warn).with(anything)
      c.username
    end
  end
end
