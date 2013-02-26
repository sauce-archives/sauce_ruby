# Sauce for Ruby

[![Build Status](https://travis-ci.org/sauce-labs/sauce_ruby.png)](https://travis-ci.org/sauce-labs/sauce_ruby)

Sauce is a Selenium-based browser testing service offered by [Sauce
Labs](https://www.saucelabs.com).


There is more information on **[the
wiki](https://github.com/saucelabs/sauce_ruby/wiki)**, so be sure to look there
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
page](https://github.com/saucelabs/sauce\_ruby/wiki/Cucumber-and-Capybara).

## Running on against a list of browsers
To run against a list of browsers, you need to configure them:

```Sauce.config do |c|
     c.browsers = [
       ["windows","firefox","18"],
       ["windows","opera","11"]
     ]
   end
```

Then, depending on your test framework:

### RSpec 2
Place your specs in the ```spec/selenium``` folder

### RSpec 1
Give your tests a :type of :selenium, eg ```describe Aioli, :type => :selenium do```

Tests will be run against each combination, sequentially and automagically.

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
* If you'd like to run the *entire* test suit, `rake test` will run all the
  integration tests, but requires the Sauce credentials to be set up properly
  as these tests will run actual jobs on Sauce.
