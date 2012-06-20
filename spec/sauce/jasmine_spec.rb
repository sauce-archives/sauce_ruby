require 'spec_helper'
require 'sauce/jasmine'

describe Sauce::Jasmine::Driver do
  describe '#initialize' do
    let(:address) { 'http://saucelabs.com' }
    let(:browser) { 'firefox' }

    it 'should take set the @http_address' do
      Sauce::Selenium2.stub(:new)
      d = Sauce::Jasmine::Driver.new(browser, address)
      d.http_address.should equal(address)
    end

    it 'should initialize a Sauce driver' do
      Sauce::Selenium2.should_receive(:new).with(hash_including(:browser => browser)).and_return(true)
      d = Sauce::Jasmine::Driver.new(browser, address)
      d.should_not be_nil
    end
  end
end


describe Jasmine::Config do
  describe '#start' do
    before :each do
      # Stub out the creation of the Selenium2 driver itself
      Sauce::Selenium2.stub(:new)
      Sauce::Jasmine::Driver.stub(:new).and_return(driver)
    end

    let(:driver) do
      driver = mock('Sauce::Jasmine::Driver')
      driver.stub(:connect)
      driver
    end

    it 'should create a Sauce::Jasmine::Driver' do
      Sauce::Jasmine::Driver.should_receive(:new).and_return(driver)
      subject.start
      subject.instance_variable_get(:@client).should be driver
    end

    it 'should call connect on the driver' do
      driver.should_receive(:connect)
      subject.start
    end
  end
end
