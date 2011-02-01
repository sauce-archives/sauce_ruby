require File.expand_path("../helper.rb", __FILE__)

class TestIntegrations < Test::Unit::TestCase
  @@globally_setup = false

  def setup
    if !@@globally_setup
      ensure_rvm_installed
      Dir.chdir File.expand_path("../..", __FILE__) do
        silence_stream(STDOUT) do
          system("gem build sauce.gemspec")
        end
      end
      ENV['SAUCE_GEM'] = File.expand_path("../../"+Dir.entries(".").select {|f| f =~ /sauce-.*.gem/}.sort.last, __FILE__)
      @@globally_setup = true
    end
  end

  def run_with_ruby(ruby_version, test)
    ruby_version = RVM.list_strings.find {|version| version =~ /#{ruby_version}/}
    if ruby_version.nil?
      RVM.install ruby_version
      ruby_version = RVM.list_strings.find {|version| version =~ /#{ruby_version}/}
    end

    gemset_name = "saucegem_#{test.to_s}"
    rubie = RVM.environment(ruby_version)
    rubie.gemset.create gemset_name
    begin
      rubie = RVM.environment("#{ruby_version}@#{gemset_name}")
      send(test, rubie)
    ensure
      rubie.gemset.delete gemset_name
    end
  end

  def run_in_environment(env, command)
    result = env.run(command)
    assert result, result.stderr
  end

  def in_tempdir
    oldwd = Dir.pwd
    temp = File.join(Dir.tmpdir, "sauce_gem_integration_test_#{rand(100000)}")
    Dir.mkdir(temp)
    Dir.chdir(temp)
    begin
      yield temp
    ensure
      Dir.chdir(oldwd)
      FileUtils.remove_dir(temp)
    end
  end

  def with_rails_3_environment(env)
    in_tempdir do |temp|
        run_in_environment(env, "gem install rails")
        run_in_environment(env, "rails new rails3_testapp")
        Dir.chdir("rails3_testapp")
        run_in_environment(env, "bundle install")
        run_in_environment(env, "rake db:migrate")
        yield
    end
  end

  def with_rails_2_environment(env)
    in_tempdir do |temp|
      run_in_environment(env, "gem install rails -v 2.3.10")
      run_in_environment(env, "gem install sqlite3")
      run_in_environment(env, "rails rails2_testapp")
      Dir.chdir("rails2_testapp")
      run_in_environment(env, "rake db:migrate")
      yield
    end
  end

  def recipe_rails3_testunit(env)
    with_rails_3_environment(env) do
      # Add some Sauce
      open("Gemfile", 'a') do |f|
        f.puts "gem 'sauce'"
      end
      run_in_environment(env, "gem install \"$SAUCE_GEM\"")
      run_in_environment(env, "bundle install")
      run_in_environment(env, "rails generate sauce:install #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

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

      run_in_environment(env, "rake test:selenium:sauce")
      run_in_environment(env, "rake test:selenium:local") unless ENV['SAUCE_TEST_NO_LOCAL']
    end
  end

  def recipe_rails3_rspec(env)
    with_rails_3_environment(env) do
      open("Gemfile", 'a') do |f|
        f.puts "gem 'sauce'"
        f.puts "gem 'rspec-rails'"
      end
      run_in_environment(env, "gem install \"$SAUCE_GEM\"")
      run_in_environment(env, "bundle install")
      run_in_environment(env, "rails generate rspec:install")

      # Add some Sauce
      run_in_environment(env, "rails generate sauce:install #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

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

      run_in_environment(env, "rake spec:selenium:sauce")
      run_in_environment(env, "rake spec:selenium:local") unless ENV['SAUCE_TEST_NO_LOCAL']
    end
  end

  def recipe_rails2_testunit(env)
    with_rails_2_environment(env) do
      run_in_environment(env, "gem install \"$SAUCE_GEM\"")
      run_in_environment(env, "script/generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

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

      run_in_environment(env, "rake test:selenium:sauce")
      run_in_environment(env, "rake test:selenium:local") unless ENV['SAUCE_TEST_NO_LOCAL']
    end
  end

  def recipe_rails2_rspec(env)
    with_rails_2_environment(env) do

      run_in_environment(env, "gem install rspec-rails -v '< 2'")
      if RUBY_VERSION >= "1.9"
        # this is a strange dependency...
        run_in_environment(env, "gem install test-unit -v 1.2.3")
      end
      run_in_environment(env, "script/generate rspec")

      # Add some Sauce
      run_in_environment(env, "gem install \"$SAUCE_GEM\"")
      run_in_environment(env, "script/generate sauce #{ENV['SAUCE_USERNAME']} #{ENV['SAUCE_ACCESS_KEY']}")

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

      run_in_environment(env, "rake spec:selenium:sauce")
      run_in_environment(env, "rake spec:selenium:local") unless ENV['SAUCE_TEST_NO_LOCAL']
    end
  end

  # Turn the recipes into tests
  self.instance_methods(false).select {|m| m =~ /recipe_.*/ }.each do |recipe|
    define_method(("test_ruby18_"+recipe).to_sym) do
      run_with_ruby("ruby-1.8.7", recipe.to_sym)
    end
    define_method(("test_ruby19_"+recipe).to_sym) do
      run_with_ruby("ruby-1.9.2", recipe.to_sym)
    end
  end
end
