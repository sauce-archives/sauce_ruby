module ChildProcess
  module Unix
    class Process < AbstractProcess

      def return_unless_timeout
        lambda do |timeout|
          begin
            return poll_for_exit timeout
          rescue TimeoutError
          end
        end
      end

      def stop(timeout = 3, signal=nil)
        assert_started

        unless signal.nil?
          send_signal signal
          return_unless_timeout.call(timeout)
        end

        send_term
        return_unless_timeout.call(timeout)

        send_kill
        wait
      rescue Errno::ECHILD, Errno::ESRCH
        # handle race condition where process dies between timeout
        # and send_kill
        true
      end
    end
  end
end