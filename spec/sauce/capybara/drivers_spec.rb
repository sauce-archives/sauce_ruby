require 'spec_helper'
require 'sauce/capybara/drivers'

describe Sauce::Capybara::Drivers::RetryableDriver do
  let(:app) { double('Mock App for Driver') }

  subject do
    Sauce::Capybara::Drivers::RetryableDriver.new(app)
  end

  it 'should be a subclass of Sauce::Capybara::Driver' do
    # There's got to be a better way do handle this
    Sauce::Capybara::Drivers::RetryableDriver.superclass.should == Sauce::Capybara::Driver
  end

  describe '#find' do
    it 'should route through handle_retry' do
      selector = '#lol'
      subject.should_receive(:base_find).with(selector) # BLECH
      subject.find(selector)
    end
  end

  describe '#visit' do
    it 'should route through #handle_retry' do
      path = '/lol'
      subject.should_receive(:base_visit).with(path)
      subject.visit(path)
    end
  end

  describe '#current_url' do
    it 'should route through #handle_retry' do
      url = 'http://lol'
      subject.should_receive(:base_current_url).and_return(url)
      subject.current_url.should == url
    end
  end
end
