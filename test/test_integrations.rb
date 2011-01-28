require File.expand_path("../helper.rb", __FILE__)

class TestIntegrations < Test::Unit::TestCase
  def setup
    ensure_rvm_installed
    Dir.chdir File.expand_path("../..", __FILE__) do
      system("gem build sauce.gemspec")
    end
    ENV['SAUCE_GEM'] = File.expand_path("../../"+Dir.entries(".").select {|f| f =~ /sauce-.*.gem/}.sort.last, __FILE__)
  end

  def test_ruby18
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.8/}
    if ruby_version.nil?
      RVM.install "ruby-1.8.7"
    end
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.8/}
    run_with_ruby(ruby_version)
  end

  def test_ruby19
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.9/}
    if ruby_version.nil?
      RVM.install "ruby-1.9.2"
    end
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.9/}
    run_with_ruby(ruby_version)
  end

  def run_with_ruby(ruby_version)
    Dir.entries(File.expand_path("../integrations", __FILE__)).find {|entry| entry =~ /\.rb$/ }.each do |integration_test|
      name = integration_test.split(".")[0]
      test_file = File.expand_path("../integrations/#{integration_test}", __FILE__)
      rubie = RVM.environment(ruby_version)
      gemset_name = "saucegem_#{name}"
      rubie.gemset.create gemset_name
      begin
        rubie = RVM.environment("#{ruby_version}@#{gemset_name}")
        output = rubie.ruby("\"#{test_file}\"")
        unless output.successful?
          puts "==== #{test_file} with Ruby #{ruby_version} ===="
          puts "===== STDOUT ====="
          print output.stdout
          puts "===== STDERR ====="
          $stderr.print output.stderr
          puts "===== END ====="
        end
        assert output.successful?, "#{integration_test} failed on Ruby #{ruby_version}"
      ensure
        rubie.gemset.delete gemset_name
      end
    end

  end

  def with_rails_3_environment
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
    begin
      yield
    ensure
      FileUtils.remove_dir(@temp)
    end
  end

  def test_rails3_testunit
    with_rails_3_environment do
      # Add some Sauce
      open("Gemfile", 'a') do |f|
        f.puts "gem 'sauce'"
      end
      system("gem install $SAUCE_GEM")
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
  end
end
