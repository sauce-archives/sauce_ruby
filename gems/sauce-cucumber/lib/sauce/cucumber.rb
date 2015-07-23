require 'capybara'
require 'cucumber'
require 'sauce/job'
require 'sauce/capybara'
require 'sauce/utilities'
require 'sauce/test_base'
require 'sauce_whisk'

module Sauce
  module Capybara
    module Cucumber
      extend Sauce::TestBase

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

      def file_name_from_scenario(scenario)
        if scenario.instance_of? ::Cucumber::Ast::OutlineTable::ExampleRow
          table = scenario.instance_variable_get(:@table)
          outline = table.instance_variable_get(:@scenario_outline)
          return {:file => outline.feature.file, :line => outline.feature.line}
        end
        return {:file => scenario.location.file, :line => scenario.location.line}
      end
      module_function :file_name_from_scenario

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
        if Sauce::Config.new[:start_tunnel]
          Sauce::Utilities::Connect.start(:quiet => true)
        end

        ::Capybara.current_driver = :sauce

        job_name = Sauce::Capybara::Cucumber.name_from_scenario(scenario)
        custom_data = {}

        if using_jenkins?
          custom_data.merge!({:commit => ENV['GIT_COMMIT'] || ENV['SVN_COMMIT'],
                       :jenkins_node => ENV['NODE_NAME'],
                       :jenkins_job => ENV['JOB_NAME']})
        end

        Sauce.config do |c|
          c[:name] = Sauce::Capybara::Cucumber.name_from_scenario(scenario)
        end

        fn = file_name_from_scenario(scenario)
        config = Sauce::Config.new
        platforms = config.caps_for_location("./#{fn[:file]}", fn[:line])

        test_each platforms, job_name do |selenium, caps|
          @selenium = selenium

          Sauce.driver_pool[Thread.current.object_id] = @selenium

          driver = ::Capybara.current_session.driver
          # This session_id is the job ID used by Sauce Labs, we're pulling it
          # off of the driver now to make sure we have it after `block.call`
          session_id = driver.browser.session_id

          if using_jenkins?
            # If we're running under Jenkins, we should dump the
            # `SauceOnDemandSessionID` into the Console Output for the Sauce OnDemand
            # Jenkins plugin.
            # See: <https://github.com/sauce-labs/sauce_ruby/issues/48>
            output = []
            output << "\nSauceOnDemandSessionID=#{session_id}"
            # The duplication in the scenario_name comes from the fact that the
            # JUnit formatter seems to do the same, so in order to get the sauce
            # OnDemand plugin for Jenkins to co-operate, we need to double it up as
            # well
            browser = caps[:browser]
            version = caps[:browser_version]
            os = caps[:os]

            job_name = "job-name=#{Sauce::Capybara::Cucumber.jenkins_name_from_scenario(scenario)}"
            output << job_name
            puts output.join(' ')
            puts " (#{browser} #{version} on #{os})" if ENV["TEST_ENV_NUMBER"]
          end

          job = SauceWhisk::Job.new('id' => session_id,
                               'name' => job_name,
                               'custom-data' => custom_data)
          job.save unless job.nil?

          scenario.sauce_public_link = SauceWhisk.public_link(session_id)

          # This allow us to execute steps (n) times
          is_example_row = scenario.instance_of? ::Cucumber::Ast::OutlineTable::ExampleRow
          steps = is_example_row ? scenario.instance_variable_get(:@step_invocations) : scenario.steps

          steps.each do |step|
            step.instance_variable_set(:@skip_invoke, false)
          end

          block.call

          # Quit the driver to allow for the generation of a new session_id
          driver.finish!

          unless job.nil?
            if scenario.failed?
              job.passed = false
            
            # Cuke scenarios with 'Pending' steps are marked 'Passed' by Cucumber
            # So if they're not 'failed' but are excepted, they're 'pending' so we 
            # don't want to change the status.
            elsif !scenario.exception
              job.passed = true
            end
            job.save
          end

          puts "Sauce public job link: #{scenario.sauce_public_link}"
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

  at_exit do
    Sauce::Utilities::Connect.close
    Sauce::Utilities.warn_if_suspect_misconfiguration(:cucumber)
  end

rescue NoMethodError # This makes me sad
end


begin
  cucumber_ast_module = Cucumber::VERSION >= '2.0.0' ? Cucumber::Core::Ast : Cucumber::Ast
  cucumber_ast_module.module_exec do

    const_get(:Scenario).class_exec do
      def sauce_public_link
        @sauce_public_link ||= ""
      end

      def sauce_public_link=(link)
        @sauce_public_link = link
      end
    end

    const_get(:OutlineTable).const_get(:ExampleRow).class_exec do
      def sauce_public_link
        @sauce_public_link ||= ""
      end

      def sauce_public_link=(link)
        @sauce_public_link = link
      end
    end
  end
end
