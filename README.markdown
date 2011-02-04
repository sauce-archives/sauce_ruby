Sauce OnDemand is a Selenium testing cloud service, developed by Sauce
Labs Inc (saucelabs.com). This is the Ruby client adapter for Sauce
OnDemand.

Features
--------

*   Drop-in replacement for Selenium::Client::Driver that takes care of connecting to Sauce OnDemand
*   RSpec, Test::Unit, and Rails integration for tests, including automatic setup of Sauce Connect
*   ActiveRecord-like interface for tunnels and jobs: Find/create/destroy

Install
-------

`gem install sauce`

Rails Integration
-------

You can use either RSpec or Test::Unit with Rails and Sauce OnDemand.  To get started, run the generator:

`script/generate sauce USERNAME ACCESS_KEY`

The generator will take care of setting up your helpers with Sauce OnDemand
configuration, which you can tweak inside the `Sauce.config` block if necessary.

### Example RSpec test for Rails

Here's an example test for RSpec.  Drop something like this in spec/selenium/example.rb:

    require "spec_helper"
    
    describe "my app" do
      it "should have a home page" do
        page.open "/"
        page.is_text_present("Welcome Aboard").should be_true
      end
    end

Here's how you run RSpec tests with Sauce OnDemand using rake:

`rake spec:selenium:sauce`

### Example Test::Unit test for Rails

Here's an example test for Test::Unit.  Drop something like this in test/selenium/example.rb:

    require "test_helper"
    
    class DemoTest < Sauce::RailsTestCase
      test "my app", do
        page.open "/"
        page.is_text_present("Welcome Aboard").should be_true
      end
    end

Here's how you run Test::Unit tests with Sauce OnDemand using rake:

`rake test:selenium:sauce`

RSpec integration without Rails
-------------------------------

First, configure with your account info:

`sauce config USERNAME ACCESS_KEY`

And here's an example test:

    #!/usr/bin/env ruby
    #
    # Sample RSpec test case using the Sauce gem
    #
    require "rubygems"
    require "sauce"
    
    # This should go in your spec_helper.rb file if you have one
    Sauce.config do |config|
      config.browser_url = "http://saucelabs.com/"
      config.browsers = [
        ["Linux", "firefox", "3.6."]
      ]
    
      # uncomment this if your server is not publicly accessible
      #config.application_host = "localhost"
      #config.application_port = "80"
    end
    
    # If this goes in spec/selenium/foo_spec.rb, you can omit the :type parameter
    describe "The Sauce Labs website", :type => :selenium do
      it "should have a home page" do
        page.open "/"
        page.is_text_present("Sauce Labs").should be_true
      end
    
      it "should have a pricing page" do
        page.open "/"
        page.click "link=Pricing"
        page.wait_for_page_to_load 30000
        page.is_text_present("Free Trial").should be_true
      end
    end

Test::Unit integration without Rails
------------------------------------

First, configure with your account info:

`sauce config USERNAME ACCESS_KEY`

And here's an example test:

    #!/usr/bin/env ruby
    #
    # Sample Test:Unit test case using the Sauce gem
    #
    require "test/unit"
    require "rubygems"
    require "sauce"
    
    # This should go in your test_helper.rb file if you have one
    Sauce.config do |config|
      config.browser_url = "http://saucelabs.com/"
      config.browsers = [
        ["Linux", "firefox", "3.6."]
      ]
    
      # uncomment this if your server is not publicly accessible
      #config.application_host = "localhost"
      #config.application_port = "80"
    end
    
    class ExampleTest < Sauce::TestCase
        def test_sauce
            page.open "/"
            assert page.title.include?("Sauce Labs")
        end
    end

Direct use of the Selenium Client driver
----------------------------------------

First, configure with your account info:

`sauce config USERNAME ACCESS_KEY`

And here's an example test:

    require 'rubygems'
    require 'sauce'
    selenium = Sauce::Selenium.new(:browser_url => "http://saucelabs.com",
        :browser => "firefox", :browser_version => "3.", :os => "Windows 2003",
        :job_name => "My first test!")
    selenium.start
    selenium.open "/"
    selenium.stop

Note on Patches/Pull Requests
----------------------------- 

*   Fork the project.
*   Make your feature addition or bug fix.
*   Add tests for it. This is important so we don't break it in a future version unintentionally.
*   Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
*   Send me a pull request. Bonus points for topic branches.

Testing the Gem
---------------

The tests in test/ need a bit of setup to get running:

if you're on Ubuntu:

* sudo aptitude install expect libsqlite3-dev

For all platforms:

* Install RVM: bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
* If you're in a headless environment, set SAUCE_TEST_NO_LOCAL=y in your environment
* Set SAUCE_USERNAME and SAUCE_ACCESS_KEY in your environment to valid Sauce OnDemand credentials
* bundle install
* rake test

If you want tests to go a bit faster, globally install the gems with native extensions:

* rvm use 1.8.7@global
* gem install ffi sqlite3 json
* rvm use 1.9.2@global
* gem install ffi sqlite3 json
* rvm use default

Plans
-----

*   Webrat integration
*   Extend to automatic retrieval of jobs logs, videos, reverse tunnels

Copyright
---------

Copyright (c) 2009-2011 Sauce Labs Inc. See LICENSE for details.
