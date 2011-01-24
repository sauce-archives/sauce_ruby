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
    open("Gemfile", 'wb') do |file|
      file.write(gemfile = <<-GEMFILE)
        source 'http://rubygems.org'
        gem 'rails', '2.3.10'
        gem 'sqlite3'
      GEMFILE
    end
    system("bundle install")
  end

  def teardown
    FileUtils.remove_dir(@temp)
  end
end

