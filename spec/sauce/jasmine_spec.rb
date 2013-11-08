require 'spec_helper'
require 'sauce/jasmine'

describe Jasmine::SeleniumDriver do
  describe '#initialize' do
    let(:address) { 'http://saucelabs.com' }
    let(:browser) { 'firefox' }

    it 'should take set the @http_address' do
      Sauce::Selenium2.stub(:new)
      d = Jasmine::SeleniumDriver.new(browser, address)
      d.http_address.should equal(address)
    end

    it 'should initialize a Sauce driver' do
      Sauce::Selenium2.should_receive(:new).with(anything).and_return(true)
      d = Jasmine::SeleniumDriver.new(browser, address)
      d.should_not be_nil
    end
  end
end


describe Jasmine::Configuration do
  describe '#port' do
    it 'returns 3001' do
      expect(Jasmine::Configuration.new.port).to eq(3001)
    end
  end
end
