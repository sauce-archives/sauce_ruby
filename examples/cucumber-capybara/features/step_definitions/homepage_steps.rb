
Given /^I am browsing the web$/ do
  # no-op
end

When /^I visit "([^"]*)"$/ do |aUrl|
  unless aUrl.start_with? 'https'
    aUrl = "https://#{aUrl}"
  end
  visit aUrl
end

Then /^I should (not )?be delighted$/ do |inverse|
  expected = 'https://saucelabs.com/'
  unless inverse
    current_url.should == expected
  else
    current_url.should_not == expected
  end
end

