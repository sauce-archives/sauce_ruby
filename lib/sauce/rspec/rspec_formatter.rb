begin
  require 'rspec/core/formatters/base_text_formatter'
  module RSpec
    module Core
      module Formatters
        class BaseTextFormatter
          def dump_failure(example, index)
            output.puts "#{short_padding}#{index.next}) #{example.full_description}"
            puts "#{short_padding}Sauce public job link: #{example.metadata[:sauce_public_link]}"
            dump_failure_info(example)
          end
        end
      end
    end
  end
rescue LoadError
  # User isn't using RSpec
end