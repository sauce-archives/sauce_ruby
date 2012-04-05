module Sauce
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Prep application for Sauce OnDemand Selenium tests"

      argument :username, :type => :string, :required => false
      argument :api_key, :type => :string, :required => false

      def copy_rake_tasks
        copy_file "sauce.rake", "lib/tasks/sauce.rake"
      end

      def configure_credentials
        if username
          system("sauce config #{username} #{api_key}")
        end
      end

      def setup_spec
        if File.directory? 'spec'
          empty_directory "spec/selenium"
          append_file "spec/spec_helper.rb", generate_config
        end
      end

      def setup_test
        if File.directory? 'test'
          empty_directory "test/selenium"
          append_file "test/test_helper.rb", generate_config
        end
      end

      private

      def generate_config
        @random_id ||= rand(100000)
        return <<-CONFIG

require 'sauce'

Sauce.config do |conf|
    conf.browsers = [
        ["Windows 2003", "firefox", "3.6."]
    ]
    conf.application_host = "127.0.0.1"
    conf.application_port = "3001"
    conf.browser_url = "http://localhost:3001/"
end
          CONFIG
      end
    end
  end
end
