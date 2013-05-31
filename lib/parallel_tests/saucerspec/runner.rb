require "yaml"
require "parallel_tests/rspec/runner"

module ParallelTests
  module Saucerspec
    class Runner < ParallelTests::RSpec::Runner

      def self.run_tests(test_files, process_number, num_processes, options)
        exe = executable # expensive, so we cache
        version = (exe =~ /\brspec\b/ ? 2 : 1)
        cmd = [exe, options[:test_options], (rspec_2_color if version == 2), spec_opts, *test_files].compact.join(" ")
        env = Sauce::TestBroker.next_environment(test_files)
        env << " #{rspec_1_color}" if version == 1
        options = options.merge(:env => env)
        execute_command(cmd, process_number, num_processes, options)
      end


      def self.tests_in_groups(tests, num_groups, options={})
        all_tests = super.flatten * Sauce::TestBroker.test_platforms.length
        base_group_size = all_tests.length / num_groups
        num_full_groups = all_tests.length - (base_group_size * num_groups)

        curpos = 0
        groups = []
        num_groups.times do |i|
          group_size = base_group_size
          if i < num_full_groups
            group_size += 1
          end
          groups << all_tests.slice(curpos, group_size)
          curpos += group_size
        end

        groups
      end
    end
  end
end
