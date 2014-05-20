require 'sauce'
require 'rails'
module Sauce
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'sauce/version'
      require 'sauce/utilities/rake'
      require 'tasks/parallel_testing'
    end
  end
end