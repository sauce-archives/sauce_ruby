require 'sauce'
require 'rails'
module Sauce
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'sauce/version'
      require 'sauce/utilities'
      require 'sauce/utilities/rake'
      require 'sauce/job'
      require 'sauce/client'
      require 'sauce/config'
      require 'sauce/selenium'
      require 'sauce/rspec'
      require 'sauce/test_unit'
      require 'tasks/parallel_testing'
      require 'parallel_tests/saucerspec/runner'
      require 'parallel_tests/saucecucumber/runner'
    end
  end
end