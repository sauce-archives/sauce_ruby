require 'capybara'
require 'cucumber'
require 'sauce/job'

module Sauce
  module Capybara
    module Cucumber
      def use_sauce_driver
        ::Capybara.current_driver = :sauce
      end
      module_function :use_sauce_driver

      def name_from_scenario(scenario)
        # Special behavior to handle Scenario Outlines
        if scenario.instance_of? ::Cucumber::Ast::OutlineTable::ExampleRow
          table = scenario.instance_variable_get(:@table)
          outline = table.instance_variable_get(:@scenario_outline)
          return "#{outline.feature.file} - #{outline.title} - #{table.headers} -> #{scenario.name}"
        end
        scenario, feature = _scenario_and_feature_name(scenario)
        return "#{feature} - #{scenario}"
      end
      module_function :name_from_scenario

      def jenkins_name_from_scenario(scenario)
        # Special behavior to handle Scenario Outlines
        if scenario.instance_of? ::Cucumber::Ast::OutlineTable::ExampleRow
          table = scenario.instance_variable_get(:@table)
          outline = table.instance_variable_get(:@scenario_outline)
          return "#{outline.feature.short_name}.#{outline.title}.#{outline.title} (outline example: #{scenario.name})"
        end
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

      def using_jenkins?
        # JENKINS_SERVER_COOKIE seems to be as good as any sentinel value to
        # determine whether we're running under Jenkins or not.
        ENV['JENKINS_SERVER_COOKIE']
      end
      module_function :using_jenkins?

      def around_hook(scenario, block)
        ::Capybara.current_driver = :sauce
        driver = ::Capybara.current_session.driver
        # This session_id is the job ID used by Sauce Labs, we're pulling it
        # off of the driver now to make sure we have it after `block.call`
        session_id = driver.browser.session_id
        job_name = Sauce::Capybara::Cucumber.name_from_scenario(scenario)
        custom_data = {}

        if using_jenkins?
          custom_data.merge!({:commit => ENV['GIT_COMMIT'] || ENV['SVN_COMMIT'],
                       :jenkins_node => ENV['NODE_NAME'],
                       :jenkins_job => ENV['JOB_NAME']})
        end

        job = Sauce::Job.new('id' => session_id,
                             'name' => job_name,
                             'custom-data' => custom_data)
        job.save unless job.nil?

        Sauce.config do |c|
          c[:name] = Sauce::Capybara::Cucumber.name_from_scenario(scenario)
        end

        if using_jenkins?
          # If we're running under Jenkins, we should dump the
          # `SauceOnDemandSessionID` into the Console Output for the Sauce OnDemand
          # Jenkins plugin.
          # See: <https://github.com/saucelabs/sauce_ruby/issues/48>
          output = []
          output << "\nSauceOnDemandSessionID=#{session_id}"
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

        unless job.nil?
          job.passed = !scenario.failed?
          job.save
        end
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
