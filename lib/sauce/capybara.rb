require 'capybara'

require 'sauce/config'
require 'sauce/connect'
require 'sauce/selenium'


$sauce_tunnel = nil

module Sauce
  module Capybara
    def connect_tunnel(options={})
      unless $sauce_tunnel.nil?
        return $sauce_tunnel
      end
      $sauce_tunnel = Sauce::Connect.new(options)
      $sauce_tunnel.connect
      $sauce_tunnel.wait_until_ready
      $sauce_tunnel
    end
    module_function :connect_tunnel

    class Driver < ::Capybara::Selenium::Driver
      def browser
        unless @browser
          if Sauce.get_config[:start_tunnel]
            Sauce::Capybara.connect_tunnel(:quiet => true)
          end

          @browser = Sauce::Selenium2.new
          at_exit do
            @browser.quit if @browser
            $sauce_tunnel.disconnect if $sauce_tunnel
          end
        end
        @browser
      end
    end
  end
end

Capybara.register_driver :sauce do |app|
  Sauce::Capybara::Driver.new(app)
end

# Monkeypatch Capybara to not use :selenium driver
require 'capybara/dsl'
module Capybara
  def self.javascript_driver
    @javascript_driver || :sauce
  end
end

# Switch Cucumber stories tagged with @selenium to use sauce
begin
  Before('@selenium') do
    Capybara.current_driver = :sauce
  end

  Around('@selenium') do |scenario, block|
    # If we're running under Jenkins, we should dump the
    # `SauceOnDemandSessionID` into the Console Output for the Sauce OnDemand
    # Jenkins plugin.
    # See: <https://github.com/saucelabs/sauce_ruby/issues/48>
    Capybara.current_driver = :sauce
    driver = Capybara.current_session.driver
    scenario_name = scenario.name.split("\n").first
    feature_name = scenario.feature.short_name

    # JENKINS_SERVER_COOKIE seems to be as good as any sentinel value to
    # determine whether we're running under Jenkins or not.
    if ENV['JENKINS_SERVER_COOKIE']
      output = []
      output << "\nSauceOnDemandSessionID=#{driver.browser.session_id}"
      # The duplication in the scenario_name comes from the fact that the
      # JUnit formatter seems to do the same, so in order to get the sauce
      # OnDemand plugin for Jenkins to co-operate, we need to double it up as
      # well
      output << "job-name=#{feature_name}.#{scenario_name}.#{scenario_name}"
      puts output.join(' ')
    end

    block.call

    # Quit the driver to allow for the generation of a new session_id
    driver.browser.quit
    driver.instance_variable_set(:@browser, nil)
  end

rescue NoMethodError
end
