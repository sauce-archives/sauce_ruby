require "spec_helper"

describe "Capybarad Examples where Sauce is included second", :js => true do
  include Capybara::DSL
  include Sauce::RSpec::SeleniumExampleGroup
  
  context "When calling the #page method" do
    it "should get access to a Capybara Session object" do
      page.should be_a_kind_of Capybara::Session
    end

    it "should not output a deprecation message" do
      self.should_not_receive(:warn).with(page_deprecation_warning)
    end
  end

  it "should not create a new driver" do
    ::Sauce::Selenium2.should_not_receive(:new)
    visit "http://wwww.google.com"
  end
end