require 'tmpdir'
require 'fileutils'
require 'test/unit'

class TestRails3 < Test::Unit::TestCase
  def setup
    @temp = File.join(Dir.tmpdir, "sauce_gem_integration_test_#{rand(100000)}")
    Dir.mkdir(@temp)
    Dir.chdir(@temp)
    puts "testing in clean working dir #{@temp}"
    # Make clean Rails project
    system("gem install rails")
    system("rails new rails3_testapp")
    Dir.chdir("rails3_testapp")
    system("bundle install")
    system("rake db:migrate")
  end

  def test_testunit
    # Add some Sauce
    open("Gemfile", 'a') do |f|
      f.puts "gem 'sauce'"
    end
    system("bundle install")
    system("rails generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

    open("test/selenium/demo_test.rb", 'wb') do |file|
      file.write(<<-EOF)
        require "test_helper"

        class DemoTest < Sauce::RailsTestCase
          test "my app" do
            page.open "/"
            assert page.is_text_present("Welcome aboard")
          end
        end
      EOF
    end

    assert system("rake test:selenium:sauce"), "Test::Unit suite failed in Sauce OnDemand"
    assert system("rake test:selenium:local"), "Test::Unit suite failed with local Selenium"
  end

  def test_rspec2
    open("Gemfile", 'a') do |f|
      f.puts "gem 'sauce'"
      f.puts "gem 'rspec-rails'"
    end
    system("bundle install")

    # Add some Sauce
    system("rails generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

    open("spec/selenium/demo_spec.rb", 'wb') do |file|
      file.write(<<-EOF)
        require "spec_helper"

        describe "my app" do
          it "should have a home page" do
            page.open "/"
            page.is_text_present("Welcome aboard").should be_true
          end
        end
      EOF
    end

    assert system("rake spec:selenium:sauce"), "RSpec suite failed in Sauce OnDemand"
    assert system("rake spec:selenium:local"), "RSpec suite failed with local Selenium"
  end

  def teardown
    FileUtils.remove_dir(@temp)
  end
end

