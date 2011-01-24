require 'rubygems'
require 'sauce/utilities'
require 'sauce/tunnel'
require 'sauce/job'
require 'sauce/client'
require 'sauce/config'
require 'sauce/selenium'
require 'sauce/integrations'
require 'sauce/connect'

module Sauce
  @@cached_sessions = {}

  def self.cached_session(opts)
    @@cached_sessions[opts] or new_session(opts)
  end

  private

  def self.new_session(opts)
    session = nil
    if Sauce::Config.new.local?
      session = ::Selenium::Client::Driver.new(opts)
    else
      session = Sauce::Selenium.new(opts)
    end
    at_exit do
      session.stop
    end
    session.start
    @@cached_sessions[opts] = session
    return session
  end
end
