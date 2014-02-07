require "spec_helper"

describe "Capybara" do
	describe "Without :sauce tagging", :type => :feature do
    before :all do
      app = proc { |env| [200, {}, ["Hello Sauce!"]]}
      Capybara.app = app
    end

    it "should connect using the port", :js => true do
      visit "/"
      expect(page).to have_content "Hello Sauce!"
    end
  end
end