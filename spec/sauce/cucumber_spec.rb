require 'spec_helper'

require 'sauce/cucumber'
# We need to pull in the cucumber_helper to effectively test cucumbery things
require 'cucumber_helper'

module Sauce::Capybara
  describe Cucumber do
    include Sauce::Capybara::Cucumber
    include Sauce::Cucumber::SpecHelper

    describe '#use_sauce_driver' do
      before :each do
        ::Capybara.current_driver = :test
      end

      it 'should change Capybara.current_driver to :sauce' do
        use_sauce_driver
        ::Capybara.current_driver.should == :sauce
      end
    end

    describe 'generating job names' do
      context 'with a simple, standard scenario' do
        let(:scenario) do
          s = double('Cucumber::AST::Scenario')
          s.stub(:name).and_return('This is a simple scenario')
          s
        end
        let(:feature) do
          f = double('Cucumber::AST::Feature')
          f.stub(:short_name).and_return('A simple feature')
          f
        end

        before :each do
          scenario.stub(:feature).and_return(feature)
        end

        describe '#name_from_scenario' do
          it 'should generated a useful name' do
            expected = 'A simple feature - This is a simple scenario'
            name_from_scenario(scenario).should == expected
          end
        end

        describe 'jenkins_name_from_scenario' do
          it 'should generate the dotted name the Jenkins plugin wants' do
            expected = 'A simple feature.This is a simple scenario.This is a simple scenario'
            jenkins_name_from_scenario(scenario).should == expected
          end
        end
      end
    end

    context 'Around hook' do
      let(:session_id) { 'deadbeef' }
      let(:driver) do
        driver = mock('Sauce::Selenium2 Driver')
        driver.stub_chain(:browser, :quit)
        driver.stub_chain(:browser, :session_id).and_return(session_id)
        driver
      end

      before :each do
        # Need to create our nice mocked Capybara driver
        Capybara.stub_chain(:current_session, :driver).and_return(driver)
        Sauce::Job.stub(:new).and_return(nil)
      end

      context 'with a scenario outline' do
        before :each do
          $ran_scenario = 0
        end

        let(:feature) do
          """
          Feature: A dummy feature with a table
            @selenium
            Scenario Outline: Mic check
              Given a <Number>
              When I raise no exceptions
            Examples: Numbers
              | Number |
              |   1    |
              |   2    |
          """
        end

        it 'should have executed the scenario outline twice' do
          define_steps do
            Given /^a (\d+)$/ do |number|
              $ran_scenario = $ran_scenario + 1
            end
            When /^I raise no exceptions$/ do
            end
            # Set up and invoke our defined Around hook
            Around('@selenium') do |scenario, block|
              # We need to fully reference the module function here due to a
              # change in scoping that will happen to this block courtesy of
              # define_steps
              Sauce::Capybara::Cucumber.around_hook(scenario, block)
            end
          end

          run_defined_feature feature
          $ran_scenario.should == 2
        end

      end

      context 'with a correct scenario' do
        let(:feature) do
          """
          Feature: A dummy feature
            @selenium
            Scenario: A dummy scenario
              Given a scenario
              When I raise no exceptions
          """
        end

        before :each do
          # Using this gnarly global just because it's easier to just use a
          # global than try to fish the scenario results back out of the
          # Cucumber bits
          $ran_scenario = nil
        end

        it 'should have executed the feature once' do
          define_steps do
            Given /^a scenario$/ do
            end
            When /^I raise no exceptions$/ do
              $ran_scenario = true
            end
            # Set up and invoke our defined Around hook
            Around('@selenium') do |scenario, block|
              # We need to fully reference the module function here due to a
              # change in scoping that will happen to this block courtesy of
              # define_steps
              Sauce::Capybara::Cucumber.around_hook(scenario, block)
            end
          end

          # Make sure we actually configure ourselves
          Sauce.should_receive(:config)
          run_defined_feature feature
          $ran_scenario.should be true
        end
      end
    end
  end
end

