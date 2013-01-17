
Given /^I am browsing the web$/ do
  # no-op
end

When /^I visit "([^"]*)"$/ do |aUrl|
  unless aUrl.start_with? 'http'
    aUrl = "http://#{aUrl}"
  end
  visit aUrl
end

Then /^I should (not )?be delighted$/ do |inverse|
  expected = %r{http(s)?://saucelabs.com/}
  unless inverse
    expected.match(current_url).should be_true
  else
    expected.match(current_url).should_not be_true
  end
end

                                 
