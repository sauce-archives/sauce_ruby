module ParallelTests
  class CLI
    def run_tests_in_parallel(num_processes, options)
      test_results = nil

      report_time_taken do
        groups = @runner.tests_in_groups(options[:files], num_processes, options)
        Sauce::TestBroker.test_groups = groups
        report_number_of_tests(groups)

        test_results = execute_in_parallel(groups, groups.size, options) do |group|
          run_tests(group, Sauce::TestBroker.group_index(group), num_processes, options)
        end

        report_results(test_results)
      end

      abort final_fail_message if any_test_failed?(test_results)
    end
  end
end