require 'sauce/version'
require 'sauce/utilities'
require 'sauce/job'
require 'sauce/client'
require 'sauce/config'
require 'sauce/selenium'
require 'sauce/integrations'
require 'tasks/parallel_testing'
require 'parallel_tests/saucerspec/runner'

# Ruby before 1.9.3-p382 does not handle exit codes correctly when nested
if RUBY_VERSION == "1.9.3" && RUBY_PATCHLEVEL < 392
  module Kernel
    alias :existing_at_exit :at_exit
    def at_exit(&block)
      existing_at_exit do
        exit_status = $!.status if $!.is_a?(SystemExit)
        block.call
        exit exit_status if exit_status
      end
    end
  end
end
