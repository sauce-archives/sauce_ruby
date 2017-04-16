#[DEPRECATED] Sauce Labs does not recommend this gem. It will not receive further development or support.

# Sauce for Ruby

[![Build Status](https://travis-ci.org/saucelabs/sauce_ruby.png)](https://travis-ci.org/saucelabs/sauce_ruby)
[![Dependency Status](https://gemnasium.com/saucelabs/sauce_ruby.png)](https://gemnasium.com/saucelabs/sauce_ruby)

This is the Ruby client adapter for testing with [Sauce
Labs](https://www.saucelabs.com), the multi-platform, multi-device testing service.  The gem supports opening Sauce Connect tunnels, starting Rails applications, and most importantly, running your tests in parallel across multiple platforms.

Be sure to check **[the wiki](https://github.com/saucelabs/sauce_ruby/wiki)** for more information, guides and support.
## Installation

```ruby
# Gemfile
gem "sauce"
gem "sauce-connect" # Sauce Connect is required by default.
```
```bash
$ bundle install
```

Configure your access credentials as environment variables:
```bash
SAUCE_USERNAME= Your Username
SAUCE_ACCESS_KEY = Your Access Key, found on the lower left of your Account page (NOT your password)
```

If environment variables aren't your thing, check out the [(in)Complete guide to Configuration](https://github.com/saucelabs/sauce_ruby/wiki/Configuration----The-\(in\)Complete-Guide) for other options.

### Appium Tests
The Sauce gem does not currently support WebDriver 3.0 style capabilities correctly.  This means that the gem can not be used to run tests against sessions using Appium 1.0 and above, including mobile browser tests.

### RSpec
```bash
$ bundle exec rake sauce:install:spec
```

Tag each example group you wish to use Sauce to run with `:sauce => true`:

```ruby
describe "A Saucy Example Group", :sauce => true do
  it "will run on sauce" do
    # SNIP
  end
end
```

Place your Sauce.config block in spec_helper.rb

### Test::Unit
Create test/sauce\_helper.rb with your desired config, and `require sauce_helper` in your test_helper.rb

### Cucumber
```ruby
## Gemfile
gem "sauce-cucumber", :require => false
gem "sauce"
```
```bash
$ bundle install
$ bundle exec rake sauce:install:features
```

Edit features/support/sauce_helper.rb with your desired config.

Tag your Sauce-intended features with `@selenium`.

## Using the gem
### RSpec
Every test with Sauce behaviour included gets access to its own selenium driver, already connected to a Sauce job and ready to go.

This driver is a Sauce subclassing of the Selenium driver object, and responds to all the same functions.

It's available as `page`, `selenium` and `s`, eg
```ruby
describe "The friend list", :sauce => true do
  it "should include at least one friend" do
    page.navigate_to "/friends"
    page.should have_content "You have friends!"
  end
end
```

We recommend, however, the use of Capybara for your tests.

#### Server Startup

If it guesses you're in a Rails project, the gem will spin up your Rails server (because it's needed for tests);  If you're using a separate server, or your specs already start one, you can prevent this in your Sauce Config:

```ruby
Sauce.config do |config|
  config[:start_local_application] = false
end
```

#### Run tests locally or remotely

A suggestion of how to run tests locally or remotely is available at the [Swappable Sauce](https://github.com/saucelabs/sauce_ruby/wiki/Swappable-Sauce) wiki page.

### Capybara
The gem provides a Capybara driver that functions mostly the same as the existing Selenium driver.
```ruby
## In your test or spec helper
require "capybara"
require "sauce/capybara"

# To run all tests with Sauce
Capybara.default_driver = :sauce

# To run only JS tests against Sauce
Capybara.javascript_driver = :sauce
```

You can now use Capybara as normal, and all actions will be executed against your Sauce session.

#### Inside an RSpec Example (tagged with :sauce => true)
If you're running from inside an RSpec example tagged with :sauce => true, the `@selenium` object and the actual driver object used by the Sauce driver are the same object.  So, if you need access to the Selenium Webdriver when using Capybara, you have it.

You'll get automagic job creation and destruction, job naming and all our nice platform support using Capybara like this.

#### Outside an RSpec Example (tagged with :js => true)
If you're not using the RSpec  hooks, Capybara will use a single Sauce Labs job until your tests exit.  You can force Capybara to close your session (and then start another):

```ruby
Capybara.current_session.driver.finish!
Capybara.reset_sessions!
```

When used like this, you won't get any of the shiny serial platform support that the :sauce tag provides;  You'll have to use our [REST API](https://saucelabs.com/docs/rest) to name your jobs (Possibly using [Sauce_Whisk](http://rubygems.org/gems/sauce_whisk) and your specs will only operate on the first platform you've specified.

#### With Sauce Connect
Sauce Connect automatically proxies content on certain ports;   Capybara.server_port will be set to a value suitable for use with Sauce Connect by default.  If you want to use a specific port, using one of these will allow Sauce Connect to tunnel traffic to your local machine:
```ruby
Capybara.server_port = an_appropriate_port

# Appropriate ports: 80, 443, 888, 2000, 2001, 2020, 2222, 3000, 3001, 3030, 3333, 4000, 4001, 4040, 4502, 4503, 5000, 5001, 5050, 5555, 6000, 6001, 6060, 6666, 7000, 7070, 7777, 8000, 8001, 8003, 8031, 8080, 8081, 8888, 9000, 9001, 9080, 9090, 9999, 49221
```
### Cucumber
The `sauce-cucumber` gem works best with Capybara.  Each "@selenium" tagged feature automatically sets the Capybara driver to :sauce.  All tagged features can simply use the Capybara DSL directly from step definitions:
```Ruby
## a_feature.rb
@selenium
Feature: Social Life
  Scenario: I have one
    Given Julia is my friend
    ## SNIP ##

## step_definition.rb
Given /^(\w+) is my friend$/ do |friends_name|
 visit "/friends/#{friends_name}"
end
```

For more details, check out the wiki page, [Cucumber and Capybara](https://github.com/saucelabs/sauce_ruby/wiki/Cucumber-and-Capybara).

### Test::Unit
To get sweeeeet Saucy features like job status updating, subclass `Sauce::TestCase` or `Sauce::RailsTestCase`.

`Sauce::TestCase` is a subclass of `Test::Unit::TestCase`, for simple test cases without anything extra.

`Sauce::RailsTestCase` is a subclass of `ActiveSupport::TestCase` so you can use all the associated ActiveSupport goodness.

Each test will have access to a fresh Sauce VM, already running and ready for commands.  The driver is a subclass of the Selenium::WebDriver class, and responds to all the same functions.  It can be accessed with the `page`, `s` and `selenium` methods.

```ruby
## test/integration/some_test.rb
require "test_helper"

class FriendList < Sauce::TestCase

  def test_the_list_can_be_opened
    page.navigate.to "/friends"
    page.should have_content "You have friends!"
  end
end
```

We still recommend the use of Capybara, see above.

### Uploading Files
Uploading files in Selenium is done by calling `send_keys` on a File input element, with the filename as the first parameter.
Remote uploads usually require you to create a File Detector and pass it to the Driver after initialization.

The gem takes care of this for you, so uploading files from your local machine during tests should "JustWork(tm)".
## Running your tests

### Setting Capabilities & Platforms
#### Setting Platforms
The `browsers` array from `Sauce.config` takes individual arrays, each representing a single platform to test against.  Each array is in the form `[platform_name_and_version, browser_name, browser_version]`.

```ruby
## Somewhere loaded by your test harness -- spec/sauce_helper or features/support/sauce_helper.rb
Sauce.config do |config|
  config[:browsers] = [
    ["Windows 7","Firefox","18"],
    ["Windows 7","Opera","11"]
  ]
end
```

#### Converting Sauce Labs capabilities
The values for the `browsers` array are terse versions of the capabilities generated by the [Sauce Labs Platform Configurator](https://docs.saucelabs.com/reference/platforms-configurator/#/);  Use the 'platform' and 'version' capabilities directly, and use the name of the object you request from `Selenium::WebDriver::Remote::Capabilities` as the browser name.  For example:

```ruby
### Platforms Configurator
caps = Selenium::WebDriver::Remote::Capabilities.chrome
caps['platform'] = 'OS X 10.10'
caps['version'] = '39.0'

### Is equivalent to
["OS X 10.10", "chrome", "39.0"]
```

#### Adding additional capabilities
##### For every platform
All the standard Selenium & Sauce capabilities are accessible from the Sauce.config block.  Some filtering is done to exclude nonsense caps.  If you need to add a capability that's not already allowed (those in `Sauce::Config::SAUCE_OPTIONS`), you can add it to the whitelist:

```ruby
Sauce.config do |config|
  # Build is already allowed
  config[:build] = "9001AMeme"

  # Shiny is not allowed yet
  config.whitelist 'shiny'
  config['shiny'] = "Something"
end
```

##### For a single platform
To set a capability for a single platform, add it as a hash to the end of the platform's array:

```ruby
Sauce.config do |config|
  config.browsers = [
    ["Windows 7", "Firefox", "18"],
    ["Windows 7", "Chrome", 30, {:build => 'ChromeTastic'}]
  ]
```

### Run tests in Parallel (Highly recommended)

```bash
$ bundle exec rake sauce:spec
$ bundle exec rake sauce:features
```

This will run your RSpec tests or Cucumber features against every platform defined, across as many concurrent Sauce sessions as your account has access too.

You can pass arguments to these tasks to control concurrency, specs/features to run and commandline arguments.

```
# Run login\spec across all platforms with up to 8 concurrent specs
$ bundle exec rake sauce:spec[spec/login_spec.rb,8]


# Run report.feature across all platforms with up to 3 concurrent features
$ bundle exec rake sauce:features[features/report.feature,3]
```

Check out the [Parallisation guide](https://github.com/sauce-labs/sauce_ruby/wiki/Concurrent-Testing) for more details.

### Run against several browsers in series
As long as your tests are correctly tagged (See installation, above), running them without the rake task (eg `$ bundle exec rspec`) will run them one at a time, once for every platform requested.

## Network Mocking

If you're mocking out external network requests, say with WebMock or FakeWeb, you'll need to ensure that requests can still be made to `saucelabs.com`, as well as any subdomains.

You'll need to ensure you can make requests _to_ your server as well.

### WebMock

We've provided a helper for `WebMock`, which you can include with `require 'sauce/webmock'`.  This will preserve all the existing config passed to `WebMock.disable_net_connect!`, while setting an exception for Sauce's servers.  You'll need to include this helper *after* any other WebMock configuration

If you want full control of your mocking, just include saucelabs.com when allowing domains:

```ruby
WebMock.disable_net_connect!(:allow => [/saucelabs.com/], "www.example.com")
```

When using the parallel testing rake tasks, the Sauce gem will reach out to the Sauce Labs REST API.  If WebMock is active during Rake tasks, you can set the `DISABLE_WEBMOCK_FOR_RAKE` environment variable to 'true' to allow this to continue.

## Reporting Results

### RSpec 2, Test::Unit and Cucumber

If integrated with RSpec (as detailed above), the gem will automatically update your jobs' success (or failure) and name using the brand spankin' new [SauceWhisk](https://github.com/DylanLacey/sauce_whisk) gem.

## Running tests against firewalled servers

If your system under test is located behind a firewall, you can use [Sauce Connect](http://www.saucelabs.com/docs/connect) to run tests through your firewall, quickly and simply.

Sauce Connect is started by default, spinning up a tunnel prior to your tests and closing it down afterwards.

To disable Sauce Connect, set `start-tunnel` to false in your Sauce.config block:

```ruby
Sauce.config do |config|
  config[:start_tunnel] = false
end
```

For details on named tunnels (including why you might want to use them) check out the [Using Identified Tunnels with Sauce Connect](https://github.com/saucelabs/sauce_ruby/wiki/Using-Identified-Tunnels-with-Sauce-Connect) page.

## Full configuration details

Check out the for a full list of configuration options and details.

This also details how to customise application/tunnel setup.

## Suggested Toolchain

The Sauce gem has been optimized to work most effectively with RSpec.

## Troubleshooting

Check the [Troubleshooting Guide](https://github.com/saucelabs/sauce_ruby/wiki/Troubleshooting)

### My tests keep erroring out with 

You're either quitting your tests inside your test blocks, _or_ something is going wrong with your test sessions.  When the gem goes to quit the sessions, they then fail.  This is revealed by design as having sessions closed during tests is considered to be bad thing.

If you're sure you want to supress this behaviour, you can do so by setting the `suppress_session_quit_failures` config value to true.

## Contributing to the Gem

* Fork the GitHub project
* Create a branch to perform your work in, this will help make your pull
  request more clear.
* Write some RSpec tests to demonstrate your desired capability or exhibit the
  bug you're fixing.
* Run the tests - `rake spec:unit` runs the unit tests, `rake spec:` followed by `connect`,`rspec` or `testunit` runs that integration test, `rake test` runs *everything*
* Make your feature addition or bug fix.
* Commit
* Send a pull request! :)

There is a [Mailing List](https://groups.google.com/forum/#!newtopic/sauce-ruby-developers) for developers.

## Logging

The gem contains a logging facility.  If left alone, it defaults to creating a `Ruby::Logger` that logs at `WARN` level to Standard Out.  You can inject your own logger:

```ruby
Sauce.logger= your_logger
```

Or, if you set the `SAUCE_LOGFILE` and `SAUCE_LOGLEVEL` environment variables, the gem will create a file logger which logs at that level.  Logfiles will be created, appended too and rotated after 10Mb.

In parallel, each logfile will have the number of the parallel process appended to the filename; The rake task will log to the first file.  Because of a quirk with how Parallel Tests numbers processes, the 'first' file will have no number, and the second will be numbered 2.

### Testing the Gem

Running the full test suite will require [RVM](http://rvm.beginrescueend.com)

* Set `SAUCE_USERNAME` and `SAUCE_ACCESS_KEY` in your environment to valid Sauce credentials **or** create an `ondemand.yml` in the following format:

        access_key: <yourkeyhere>
        username: <yourusernamehere>

* Invoke `bundle install` to install the gems necessary to work with the Sauce
  gem
* Running `rake spec:unit` will run the [RSpec](https://github.com/rspec/rspec) unit tests
* If you'd like to run the *entire* test suit, ```rake test``` will run all the
  integration tests, but requires the Sauce credentials to be set up properly
  as these tests will run actual jobs on Sauce.

### Rakefile

If you see `Exception occured: uninitialized constant Sauce::RSpec::Spec` when requiring the sauce gem in the Rakefile, make sure to require bundler/setup.

```ruby
require 'bundler/setup'
require 'sauce'
```

## References
* [Cucumber](https://www.cukes.info)     -- Cucumber, the only BDD Framework that doesn't suck.
* [Capybara](http://jnicklas.github.com/capybara/)     -- Don't handcode webdriver commands.
* [SauceWhisk](https://github.com/DylanLacey/sauce_whisk)     -- Ruby REST API Wrapper for the Sauce API.  Fresh New Minty Flavour!

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/saucelabs/sauce_ruby/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
