require "logger"

module Sauce
  def self.logger=(logger)
    @logger = logger
  end

  # Returns the set logger or, if none is set, a default logger
  def self.logger
    @logger ||= default_logger
  end

  private

  # Creates a default logger when the user hasn't set one.
  # Default logger with be STDOUT _unless_ the `SAUCE_LOGFILE` environment var
  # has been set, in which case that file will be appended to, until it is
  # 10240 bytes, when it will be rotated.  This will happen 10 times.
  #
  # The default logging level is WARN, but can be set with the
  # environment var SAUCE_LOGLEVEL
  def self.default_logger
    log = ::Logger.new(*default_logger_arguments)
    log.level = default_logging_level
    return log
  end

  def self.default_logger_arguments
    logfile = ENV["SAUCE_LOGFILE"]
    if logfile
      
      unless ENV["TEST_ENV_NUMBER"].nil?
        logfile = "#{logfile}#{ENV["TEST_ENV_NUMBER"]}"

      end
      log = File.open logfile, File::APPEND
      return [log, 10, 10240]
    else
      return [STDOUT]
    end
  end

  def self.default_logging_level
    case ENV.fetch("SAUCE_LOGLEVEL", "").downcase
    when 'error'
      Logger::ERROR
    when 'warn'
      Logger::WARN
    when 'info'
      Logger::INFO
    when 'debug'
      Logger::DEBUG
    else
      Logger::WARN
    end
  end
end