require 'sauce/version'
require 'sauce/utilities'
require 'sauce/job'
require 'sauce/client'
require 'sauce/config'
require 'sauce/selenium'
require 'sauce/integrations'

module Sauce
  def self.driver_pool
    @@driver_pool ||= {}
  end
end
