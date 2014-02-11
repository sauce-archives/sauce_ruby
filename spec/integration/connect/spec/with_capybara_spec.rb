require "spec_helper"

describe "Capybara" do
	describe "Without :sauce tagging", :js => true, :type => :feature do
    it "should connect using the port", :js => true do
      visit "/"
      expect(page).to have_content "Hello Sauce!"
    end
  end
end