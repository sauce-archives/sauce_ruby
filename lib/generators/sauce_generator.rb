class SauceGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  argument :username, :type => nil
  argument :api_key, :type => nil

  def copy_rake_tasks
    copy_file "sauce.rake", "lib/tasks/sauce.rake"
  end

  def setup_spec
    if File.directory? 'spec'
      empty_directory "spec/selenium"
      append_file "spec/spec_helper.rb", generate_config
    end
  end

  def setup_test
    empty_directory "test/selenium"
    append_file "test/test_helper.rb", generate_config
  end

  private

  def generate_config
    @random_id ||= rand(100000)
    return <<-CONFIG
require 'sauce'

Sauce.config do |conf|
    conf.browser_url = "http://#{@random_id}.test/"
    conf.browsers = [
        ["Windows 2003", "firefox", "3."]
    ]
    conf.application_host = "127.0.0.1"
    conf.application_port = "3001"
end
      CONFIG
  end
end
