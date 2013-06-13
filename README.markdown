# Sauce for Ruby
 
[![Build Status](https://travis-ci.org/sauce-labs/sauce_ruby.png)](https://travis-ci.org/sauce-labs/sauce_ruby)
[![Dependency Status](https://gemnasium.com/sauce-labs/sauce_ruby.png)](https://gemnasium.com/sauce-labs/sauce_ruby)

This is the Ruby client adapter for testing with [Sauce
Labs](https://www.saucelabs.com), a Selenium-based browser testing service.

The gem supports opening Sauce Connect tunnels, starting Rails applications, and most importantly, running your tests in parallel across multiple platforms.

There is more information on **[the
wiki](https://github.com/sauce-labs/sauce_ruby/wiki)**, so be sure to look there
for information too!

## Installation

```ruby
# Gemfile
gem "sauce"
gem "sauce-connect" # Sauce Connect is required by tests by default.
```
```bash
$ bundle install
```
### RSpec
```bash
$ bundle exec rake sauce:install:spec
```

Edit spec/sauce_helper.rb with your desired config.

Tag your tests `:sauce => true` or place them in the `spec/selenium` directory to get the Sauce behaviours included.

### Test::Unit
Create test/sauce_helper.rb with your desired config, and `require sauce_helper` in your test_helper.rb

### Cucumber
```ruby
## Gemfile
gem "sauce-cucumber"
```
```bash
$ bundle install
$ bundle exec rake sauce:install:features
```

Edit features/support/sauce_helper.rb with your desired config.

Tag your features with `@selenium` to get Sauce behaviour included.

## Using the gem
### RSpec
Every test with Sauce behaviour included gets access to its own selenium driver, already connected to a Sauce job and ready to go.

This driver is a Sauce subclassing of the Selenium driver object, and responds to all the same functions.

It's available as `page`, `selenium` and `s`, eg
```ruby
describe "The friend list" do
  it "should include at least one friend" do
    page.navigate_to "/friends"
    page.should have_content "You have friends!"
  end
end
```

We recommend, however, the use of Capybara for your tests.

### Capybara
The gem provides a Capybara driver that functions exactly the same as the existing Selenium driver.
```ruby
## In your test or spec helper
require "capybara"
require "capybara/sauce"

# To run all tests with Sauce
Capybara.default_driver = :sauce

# To run only JS tests against Sauce
Capybara.javascript_driver = :sauce

# To allow Sauce::Connect through to your application
Capybara.server_port = an_appropriate_port

# Appropriate ports: 80, 443, 888, 2000, 2001, 2020, 2222, 3000, 3001, 3030, 3333, 4000, 4001, 4040, 4502, 4503, 5000, 5001, 5050, 5555, 6000, 6001, 6060, 6666, 7000, 7070, 7777, 8000, 8001, 8003, 8031, 8080, 8081, 8888, 9000, 9001, 9080, 9090, 9999, 49221
```

You can now use Capybara as normal, and all actions will be executed against your Sauce session.

If you're running from inside a RSpec test, the `@selenium` object and the actual driver object used by the Sauce driver are the same object.  So, if you need access to the Selenium Webdriver when using Capybara, you have it.

### Cucumber
The `sauce-jasmine` gem works best with Capybara.  Each tagged feature automatically sets the Capybara driver to :sauce.  All tagged features can simply use the Capybara DSL directly from step definitions:
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

For more details, check out the wiki page, [Cucumber and Capybara](https://github.com/sauce-labs/sauce_ruby/wiki/Cucumber-and-Capybara).

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

## Running your tests

### Setting Up The Platform Array

```ruby
## Somewhere loaded by your test harness -- spec/sauce_helper or features/support/sauce_helper.rb
Sauce.config do |c|
  c.browsers = [
    ["Windows 7","Firefox","18"],
    ["Windows 7","Opera","11"]
  ]
end
```

### Run tests in Parallel (Highly recommended)

```bash
$ bundle exec sauce:spec
$ bundle exec sauce:features
```

This will run your RSpec tests or Cucumber features against every platform defined, across as many concurrent Sauce sessions as your account has access too.

Check out the [Parallisation guide](https://github.com/sauce-labs/sauce_ruby/wiki/Concurrent-Testing) for more details.

### Run against several browsers in series
As long as your tests are correctly tagged (See installation, above), running them without the rake task (eg `$ bundle exec rspec`) will run them one at a time, once for every platform requested.

## Reporting Results

### RSpec 2, Test::Unit and Cucumber

If integrated with RSpec (as detailed above), the gem will automatically update your jobs' success (or failure) and name using the brand spankin' new [SauceWhisk](https://github.com/DylanLacey/sauce_whisk) gem.

## Full configuration details

Check out the [(in)Complete guide to Configuration](https://github.com/sauce-labs/sauce_ruby/wiki/Configuration----The-\(in\)Complete-Guide) for a full list of configuration options and details.

This also details how to customise application/tunnel setup.

## Suggested Toolchain

The Sauce gem has been optimized to work most effectively with

## Contributing to the Gem

* Fork the GitHub project
* Create a branch to perform your work in, this will help make your pull
  request more clear.
* Write some RSpec tests to demonstrate your desired capability or exhibit the
  bug you're fixing.
* Make your feature addition or bug fix.
* Commit
* Send a pull request! :)

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


## References
* [Cucumber](https://www.cukes.info)     -- Cucumber, the only BDD Framework that doesn't suck.
* [Capybara](http://jnicklas.github.com/capybara/)     -- Don't handcode webdriver commands.
* [SauceWhisk](https://github.com/DylanLacey/sauce_whisk)     -- Ruby REST API Wrapper for the Sauce API.  Fresh New Minty Flavour!

