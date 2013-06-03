# Sauce for Ruby
 
[![Build Status](https://travis-ci.org/sauce-labs/sauce_ruby.png)](https://travis-ci.org/sauce-labs/sauce_ruby)
[![Dependency Status](https://gemnasium.com/sauce-labs/sauce_ruby.png)](https://gemnasium.com/sauce-labs/sauce_ruby)

This is the Ruby client adapter for testing with [Sauce
Labs](https://www.saucelabs.com), a Selenium-based browser testing service.


There is more information on **[the
wiki](https://github.com/sauce-labs/sauce_ruby/wiki)**, so be sure to look there
for information too!


## Installation

```bash
    % gem install sauce
```

## With RSpec 1 & 2
In spec/sauce_helper.rb:
```ruby
require "sauce"
```

## With Test::Unit && Mini::Test

In your test_helper.rb:
```ruby
require "sauce"
```

### With Capybara
In your test setup file (test or spec helper, most likely):
```ruby
require "capybara"
require "capybara/sauce"
```

#### Run all tests against Sauce
```ruby
Capybara.default_driver = :sauce
```

#### Run only Javascript tests against Sauce
```ruby
Capybara.javascript_driver = :sauce
```

#### With Sauce::Connect
Capybara runs a server on a random port.  Sauce::Connect expects a port from a specific range.  So, you need to pick one of :

```bash
80, 443, 888, 2000, 2001, 2020, 2222, 3000, 3001, 3030, 3333, 4000, 4001, 4040, 4502, 4503, 5000, 5001, 5050, 5555, 6000, 6001, 6060, 6666, 7000, 7070, 7777, 8000, 8001, 8003, 8031, 8080, 8081, 8888, 9000, 9001, 9080, 9090, 9999, 49221
```
Then set Capybara to do that with ```Capybara.server_port = the_chosen_port```

## Running your tests

### Set Up The Browsers Array

```ruby
Sauce.config do |c|
  c.browsers = [
    ["Windows 7","Firefox","18"],
    ["Windows 7","Opera","11"]
  ]
end
```

If you run your tests normally (eg with ```rspec```) They'll run one at a time against the Sauce Labs cloud.  The first browser from the array will be used for all tests.

If you run your tests with the rake task (```rake sauce:spec```) then your tests will be run concurrently, for as many concurrent VMs as your account is allowed, against every platform specified.

## Reporting Results

### RSpec 2

If integrated with RSpec (as detailed above), the gem will automatically update your jobs' success (or failure) and name using the brand spankin' new (SauceWhisk)[https://github.com/DylanLacey/sauce_whisk] gem.

### RSpec 1 and Test::Unit

Coming soon!  Check out (SauceWhisk)[https://github.com/DylanLacey/sauce_whisk] while you wait!

## Full configuration details

Check out the ((in)Complete guide to Configuration)[https://github.com/sauce-labs/sauce_ruby/wiki/Configuration----The-(in)Complete-Guide] for a full list of configuration options and details.

This also details how to customise application/tunnel setup.

## Suggested Toolchain

The Sauce gem has been optimized to work most effectively with
[Cucumber](https://www.cukes.info) and
[Capybara](http://jnicklas.github.com/capybara/).

To get started with Sauce and Cucumber, install the appropriate gem:

```bash
    % gem install sauce-cucumber
```

And then read more how to get started with [Cucumber and Capybara on this
wiki
page](https://github.com/sauce-labs/sauce_ruby/wiki/Cucumber-and-Capybara).

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
