module ParallelTests
  class CLI
    def run_tests_in_parallel(num_processes, options)
      test_results = nil

      report_time_taken do
        groups = @runner.tests_in_groups(options[:files], num_processes, options)
        non_empty_groups = groups.reject {|group| group.empty?}
        Sauce::TestBroker.test_groups = non_empty_groups

        report_number_of_tests(non_empty_groups)

        test_results = execute_in_parallel(non_empty_groups, non_empty_groups.size, options) do |group|
          run_tests(group, Sauce::TestBroker.group_index(group), num_processes, options)
        end

        Sauce.logger.debug "Parallel Tests reporting results."
        report_results(test_results)
      end

      abort final_fail_message if any_test_failed?(test_results)
    end
  end
end