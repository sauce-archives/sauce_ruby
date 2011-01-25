require 'tmpdir'
require 'fileutils'
require 'test/unit'

class TestRails2 < Test::Unit::TestCase
  def setup
    @temp = File.join(Dir.tmpdir, "sauce_gem_integration_test_#{rand(100000)}")
    Dir.mkdir(@temp)
    Dir.chdir(@temp)
    puts "testing in clean working dir #{@temp}"
  end

  def test_rails2
    # Make clean Rails project
    system("gem install rails -v 2.3.10")
    system("gem install sqlite3")
    system("rails rails2_testapp")
    Dir.chdir("rails2_testapp")
    system("rake db:migrate")

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

    assert system("rake test:selenium:sauce")
    assert system("rake test:selenium:local")
  end

  def teardown
    FileUtils.remove_dir(@temp)
  end
end

