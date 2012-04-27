require 'capybara'
require 'cucumber'

module Sauce
  module Capybara
    module Cucumber
      def use_sauce_driver
        ::Capybara.current_driver = :sauce
      end
      module_function :use_sauce_driver

      def name_from_scenario(scenario)
        scenario, feature = _scenario_and_feature_name(scenario)
        return "#{feature} - #{scenario}"
      end
      module_function :name_from_scenario

      def jenkins_name_from_scenario(scenario)
        scenario, feature = _scenario_and_feature_name(scenario)
        return "#{feature}.#{scenario}.#{scenario}"
      end
      module_function :jenkins_name_from_scenario

      def _scenario_and_feature_name(scenario)
        scenario_name = scenario.name.split("\n").first
        feature_name = scenario.feature.short_name
        return scenario_name, feature_name
      end
      module_function :_scenario_and_feature_name

      def before_hook
        Sauce::Capybara::Cucumber.use_sauce_driver
      end
      module_function :before_hook

      def around_hook(scenario, block)
        # If we're running under Jenkins, we should dump the
        # `SauceOnDemandSessionID` into the Console Output for the Sauce OnDemand
        # Jenkins plugin.
        # See: <https://github.com/saucelabs/sauce_ruby/issues/48>
        ::Capybara.current_driver = :sauce
        driver = ::Capybara.current_session.driver
        Sauce.config do |c|
          c[:name] = Sauce::Capybara::Cucumber.name_from_scenario(scenario)
        end

        # JENKINS_SERVER_COOKIE seems to be as good as any sentinel value to
        # determine whether we're running under Jenkins or not.
        if ENV['JENKINS_SERVER_COOKIE']
          output = []
          output << "\nSauceOnDemandSessionID=#{driver.browser.session_id}"
          # The duplication in the scenario_name comes from the fact that the
          # JUnit formatter seems to do the same, so in order to get the sauce
          # OnDemand plugin for Jenkins to co-operate, we need to double it up as
          # well
          output << "job-name=#{Sauce::Capybara::Cucumber.jenkins_name_from_scenario(scenario)}"
          puts output.join(' ')
        end

          block.call

        # Quit the driver to allow for the generation of a new session_id
        driver.browser.quit
        driver.instance_variable_set(:@browser, nil)
      end
      module_function :around_hook
    end
  end
end


begin
  Before('@selenium') do
    Sauce::Capybara::Cucumber.before_hook
  end

  Around('@selenium') do |scenario, block|
    Sauce::Capybara::Cucumber.around_hook(scenario, block)
  end
rescue NoMethodError # This makes me sad
end
