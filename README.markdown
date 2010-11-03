sauce
=====

Ruby access to Sauce OnDemand

Features
--------
Current:

*   Drop-in replacement for Selenium::Client::Driver that takes care of connecting to Sauce OnDemand
*   RSpec, Test::Unit, and Rails integration for tests, including automatic setup of Sauce Connect
*   ActiveRecord-like interface for tunnels and jobs: Find/create/destroy

Planned:

*   Extend to automatic retrieval of jobs logs, videos, reverse tunnels
*   Start/stop local instances of Sauce RC
*   Webrat integration

Install
-------
`gem install sauce`

`sauce config USERNAME ACCESS_KEY`

Examples
-------
### Selenium Client driver
    require 'rubygems'
    require 'sauce'
    selenium = Sauce::Selenium.new(:browser_url => "http://saucelabs.com",
        :browser => "firefox", :browser_version => "3.", :os => "Windows 2003",
        :job_name => "My first test!")
    selenium.start
    selenium.open "/"
    selenium.stop

### RSpec integration
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

### Test::Unit integration
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

### Rails integration
You can use either RSpec or Test::Unit with Rails and Sauce OnDemand.
The generator will take care of setting up your helpers with Sauce OnDemand
configuration, which you can tweak inside the `Sauce.config` block.

`gem install sauce`

`script/generate sauce USERNAME ACCESS_KEY`

For RSpec, drop something like this in spec/selenium:

    require "spec_helper"
    
    describe "my app" do
      it "should have a home page" do
        page.open "/"
        page.is_text_present("Welcome Aboard").should be_true
      end
    end

For Test::Unit, drop something like this in test/selenium:

    require "test_helper"
    
    class DemoTest < Sauce::RailsTestCase
      test "my app", do
        page.open "/"
        page.is_text_present("Welcome Aboard").should be_true
      end
    end

To run your tests, use rake:

`rake spec:selenium:sauce`

`rake test:selenium:sauce`

Note on Patches/Pull Requests
----------------------------- 
*   Fork the project.
*   Make your feature addition or bug fix.
*   Add tests for it. This is important so we don't break it in a future version unintentionally.
*   Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
*   Send me a pull request. Bonus points for topic branches.

Copyright
---------
Copyright (c) 2009-2010 Sauce Labs Inc. See LICENSE for details.
