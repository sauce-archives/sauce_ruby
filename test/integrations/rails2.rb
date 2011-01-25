require 'tmpdir'
require 'fileutils'
require 'test/unit'

class TestRails2 < Test::Unit::TestCase
  def setup
    @temp = File.join(Dir.tmpdir, "sauce_gem_integration_test_#{rand(100000)}")
    Dir.mkdir(@temp)
    Dir.chdir(@temp)
    puts "testing in clean working dir #{@temp}"
    system("echo yes | rvm gemset empty")
    # Make clean Rails project
    system("gem install rails -v 2.3.10")
    system("gem install sqlite3")
    system("rails rails2_testapp")
    Dir.chdir("rails2_testapp")
    system("rake db:migrate")

  end

  def test_testunit
    # Add some Sauce
    system("gem install sauce")
    system("script/generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

    open("test/selenium/demo_test.rb", 'wb') do |file|
      test_file = <<-EOF
        require "test_helper"

        class DemoTest < Sauce::RailsTestCase
          test "my app" do
            page.open "/"
            assert page.is_text_present("Welcome aboard")
          end
        end
      EOF
      file.write(test_file)
    end

    assert system("rake test:selenium:sauce"), "Test::Unit suite failed in Sauce OnDemand"
    assert system("rake test:selenium:local"), "Test::Unit suite failed with local Selenium"
  end

  def test_rspec1
    system("gem install rspec-rails -v '< 2'")
    if RUBY_VERSION >= "1.9"
      # this is a strange dependency...
      system("gem install test-unit -v 1.2.3")
    end
    system("script/generate rspec")

    # Add some Sauce
    system("gem install sauce")
    system("script/generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

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

