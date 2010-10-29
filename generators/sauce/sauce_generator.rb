require 'sauce/config'

# This generator bootstraps a Rails project for use with Sauce OnDemand
class SauceGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    config = Sauce::Config.new
    if config.username.nil? || config.access_key.nil?
      if runtime_args.size < 2
        raise "Usage: #{$0} sauce <USERNAME> <ACCESS_KEY>"
      else
        system("sauce config #{runtime_args[0]} #{runtime_args[1]}")
      end
    end
    super
  end

  def manifest
    record do |m|
      if File.directory? 'spec'
        m.directory File.join('spec', 'selenium') if File.directory? 'spec'
        m.setup_helper(File.join('spec', 'spec_helper.rb')) if File.directory? 'spec'
      end

      m.directory File.join('lib', 'tasks')
      m.directory File.join('test', 'selenium') if File.directory? 'test'
      m.file      'sauce.rake', File.join('lib', 'tasks', 'sauce.rake')
      m.setup_helper(File.join('test', 'test_helper.rb'))
    end
  end

  def setup_helper(file)
    contents = File.read(file)
    if contents !~ /Sauce.config/
      File.open(file, "a") do |file|
        file.write <<-CONFIG

require 'sauce'

Sauce.config do |conf|
    conf.browser_url = "http://#{rand(100000)}.test/"
    conf.browsers = [
        ["Windows 2003", "firefox", "3."]
    ]
    conf.application_host = "127.0.0.1"
    conf.application_port = "3001"
end
        CONFIG
      end
    end
  end

protected

  def banner
    "Usage: #{$0} sauce [<USERNAME> <ACCESS_KEY>]"
  end
end
