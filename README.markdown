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

## With Capybara && Sauce::Connect
Capybara on a random port.  Sauce::Connect expects a port from a specific range.  So, you need to pick one of :

```bash
80, 443, 888, 2000, 2001, 2020, 2222, 3000, 3001, 3030, 3333, 4000, 4001, 4040, 4502, 4503, 5000, 5001, 5050, 5555, 6000, 6001, 6060, 6666, 7000, 7070, 7777, 8000, 8001, 8003, 8031, 8080, 8081, 8888, 9000, 9001, 9080, 9090, 9999, 49221
```
Then set Capybara to do that with ```Capybara.server_port = the_chosen_port```

## The Browsers Array
When setting up the gem, you can pass a list of browsers:

```ruby
Sauce.config do |c|
  c.browsers = [
    ["windows","firefox","18"],
    ["windows","opera","11"]
  ]
end
```

Then, depending on your test framework:

### RSpec 2
Place your specs in the ```spec/selenium``` folder, or tag the example group with ```:sauce => true```

### RSpec 1
Give your tests a :type of :selenium, eg ```describe Aioli, :type => :selenium do```

Tests will be run against each combination, sequentially and automagically.  

**If you don't place your tests in these locations, only the first browser in the array will run**.

Work is continuing in magic browser delights for other tools.  (PSST:  If you have ideas, please let us know!)

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
