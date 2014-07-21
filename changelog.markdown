# Changelog
## 3.4
### 3.4.9
Fixed delegation of execute_script to Selenium webdriver

### 3.4.8
Correct hooking of post job actions.

### 3.4.7
Handle cases where Sauce returns an incorrectly escaped JSON string for 'proxy' by parsing it out again.

### 3.4.6
If it exists, return the first exception thrown when executing in serial across platforms

### 3.4.5
Include Capybara driver settings when generating sauce_helper, if required
Correctly reference example groups for RSpec 2.99.0 and up (Closes #241)
Expand the webmock helper to include all saucelabs.com domains (Closes #244)

### 3.4.4
Search for config files during parallel tasks more sensibly (Thanks @Casey Howard)
Prefer config files from the current tool, during parallel tests.
### 3.4.3
Add the iedriver-version to the capability whitelist (Thanks @QuantumGeordie!)
Allow for the use of `SAUCE_USER_NAME` and `SAUCE_API_KEY` environment variables
Add output for Jenkins job reporting (Conditional on JENKINS_SERVER_COOKIE env var)
Add post job hooks allowing for custom actions after Sauce sessions

### 3.4.2
Added Railtie to (hopefully) solve rake tasks not being available (Thanks @adambarthelson!)
Updated sauce:spec details in README (Thanks @seanknox!)
Don't stuff up the ENV hash when extracting options (Thanks @forest!)

### 3.4.1
Changed behaviour of Capybara integraton:  if start_local_application is false, Capybara will no longer set the app_port to a SauceConnect port

### 3.4.0
Changed behaviour of server startup; Now relies on presense of a selenium directory OR a :sauce tag
Changed behaviour of sauce connect integration; Ignore :application_host when starting a server
Correctly format JSON for Windows (Closes #210) (Thanks @UATcendyn!)
Never set app_host if it is already set (Closes #207) (Thanks @vgrigoruk!)
Support for RSpec 3 example metadata (Closes #178)

### 3.3.2
Change behaviour of Capybara; having `:start_local_application = false` in your Sauce.config will now let Capybara control whether or not it should start a server.
Made the #page method smarter at figuring out if it should return the Selenium object or the Capybara object.
RSpec < 2 will now report job success or failure
You can pass a hash to Sauce::Config.new including `:without_defaults => true` and uh, defaults won't be loaded.
Added a check if Sauce Connect can't connect to Sauce's servers.
Added check if parallel\_tests is already running/didn't quit.
Make Capybara always include the port for local rack applications.
Defaulted Capybara to using a Sauce Connect port.

### 3.3.1
Add Sauce Public Job Links to cucumber and rspec integrations (Thanks @imurchie!)
Tunnel accessor for Sauce::Utilities::Connect
Updated to (https://github.com/saucelabs/sauce_whisk/tree/v0.0.11)[sauce\_whisk 0.0.11
Updated to (https://github.com/grosser/parallel_tests/tree/v0.16.6)[parallel_tests 0.16.6]
Allow flattened Browsers array (Thanks @imurchie)
Remove reset override (Thanks @mrloop!)
Error message for unset username and access key (Thanks @imurchie!)
Fixed name of files argument in Rakefile (Thanks @imurchie!)

### 3.3.0
Added 'parallel\_test\_options' to rake tasks, allows for arbitrary p-tests options:
`bundle exec rake sauce:spec parallel_test_options='--group-by scenario'
Update parallel_tests to 0.16.5
Monkeypatch Capybara's reset! functionality to remove dependance on the gem's in-build empty page

## 3.2
### 3.2.0
Added ENV_VAR rake parameters for spec and cucumber tasks (concurrency, rspec_options, specs)
Added a check for correct integration:

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
