require "spec_helper"

describe "my app" do
  it "should have a home page" do
    page.open "/"
    page.is_text_present("Welcome aboard").should be_true
  end
end
