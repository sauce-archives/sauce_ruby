# Changelog
## 3.1
### 3.1.3
Added ability to pass "SAUCE\_DISABLE\_HEROKU\_CONFIG" environment variable to disable attempts to load Heroku
Enabled seamless native uploads
Corrected job\_name overwriting name in config
Corrected TestUnit examples in Examples directory for Selenium 2

### 3.1.2
Default to only running tasks tagged with ":sauce"
Allow for options to be passed to Parallel Tests when running the rspec rake task

### 3.1.1
Correctly serialize string based desired capabilitites
Correct https://github.com/saucelabs/sauce\_ruby/issues/163

### 3.1.0
Extracted Rails server config into separate file
Prevented Capybara from starting a server when already started
Made Capybara & Parallel Tests respect Sauce Connect ports
Removed default port of 80 from Sauce Connect startup

## 3.0
### 3.0.6
Added Command Line options for Sauce Connect (thanks, Rick Martínez!)

### 3.0.5
Update Parallel Tests to 0.15.0
Read :browser, :version and :os as nil if one is set and the others aren't
Added SimpleCov to base tests
Removed Gemcutter from all Gemfiles
Updated RSpec to 2.14.0
Cleaned up test output, removing deprecation warnings

### 3.0.4
Make Sauce Connect much quieter
Add a "false" flag to Sauce.get\_config to let you get without defaults
Filtered out empty groups form execution during parallel tests

### 3.0.3
Update Rake sauce_helper task to include Capybara when required
Match the default browsers with those in Sauce Labs' Ruby tutorial
Update sauce-whisk dependency to be pessimistic

### 3.0.2
Strip out extraneous config details from :desired_capabilities

### 3.0.1
Make parallel tests correctly exit when child tests exit with an error.

### 3.0.0
W00t!  Parallelization for Cucumber, RSpec.  The gem now uses parallel_tests to spin up instances of your tests across all specified browsers.  Tests are run at the lower of your concurrency limit OR 20.

Added sauce:install:spec, sauce:install:features to create config helpers
Added parallelization - Gem will now run your tests across multiple browsers and as many threads as you have Sauce VMs
Added sauce:features and sauce:spec to run tests in parallel.

## 2.5
### 2.5.1
Added Test::Unit integration for result reporting
Added better tests for above

### 2.5.0
Added RSpec 2 integration for result reporting.
