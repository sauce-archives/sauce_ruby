require 'parallel_tests'

def start_tunnel_for_parallel_tests(c)
  c[:start_tunnel] = ParallelTests.first_process?
  if ParallelTests.first_process?
    at_exit do
      if ParallelTests.first_process?
        ParallelTests.wait_for_other_processes_to_finish
      end
    end
  else
    while not File.exist? "sauce_connect.ready"
      sleep 0.5
    end
  end
end
