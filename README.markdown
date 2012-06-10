# Sauce OnDemand for Ruby

Sauce OnDemand is a Selenium-based browser testing service offered by [Sauce
Labs](https://www.saucelabs.com).


## Installation

```bash
    % gem install sauce
```


## Suggested Toolchain


The Sauce gem has been optimized to work most effectively with
[Cucumber](https://www.cukes.info) and
[Capybara](http://jnicklas.github.com/capybara/).

You can read more about how to get started with [Cucumber and Capybara on this
wiki
page](https://github.com/saucelabs/sauce\_ruby/wiki/Cucumber-and-Capybara).



## Legacy Rails Integration

You can use either RSpec or Test::Unit with Rails and Sauce OnDemand.  To get started, run the generator:

`script/generate sauce USERNAME ACCESS_KEY`

The generator will take care of setting up your helpers with Sauce OnDemand
configuration, which you can tweak inside the `Sauce.config` block if necessary.

### Example RSpec test for Rails

Here's an example test for RSpec.  Drop something like this in spec/selenium/example.rb.  (Because of the way RSpec categorizes tests, the "spec/selenium" directory tree is required for the integration to work properly):

    require "spec_helper"

    describe "my app" do
      it "should have a home page" do
        s.get 'http://localhost:3001/'
        assert s.page_source.include? 'Welcome aboard'
      end
    end

Here's how you run RSpec tests with Sauce OnDemand using rake:

`rake spec:selenium:sauce`

### Example Test::Unit test for Rails

Here's an example test for Test::Unit.  Drop something like this in test/selenium/example\_test.rb:

    require "test_helper"

    class DemoTest < Sauce::RailsTestCase
      test "my app", do
        s.get 'http://localhost:3001/'
        assert s.page_source.include? 'Welcome aboard'
      end
    end

Here's how you run Test::Unit tests with Sauce OnDemand using rake:

`rake test:selenium:sauce`


### Contributing to the Gem

*  Fork the project.
*  Make your feature addition or bug fix.
*  Please add RSpec tests for your changes, as we don't create a new release of the gem unless all tests are passing.
*  Commit
*  Send a pull request. Bonus points for topic branches.


### Testing the Gem

Running the full test suite will require [RVM](http://rvm.beginrescueend.com)

* Set SAUCE_USERNAME and SAUCE_ACCESS_KEY in your environment to valid Sauce OnDemand credentials
* bundle install
* rake spec:unit # Will just run the unit tests
* rake test      # Will run *all* the tests and can be slow

