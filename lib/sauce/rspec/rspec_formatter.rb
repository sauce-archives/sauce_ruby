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
rescue NameError
  # User is using RSpec 3
end

begin
  require 'rspec/core/formatters/exception_presenter'
  module RSpec
    module Core
      module Formatters
        class ExceptionPresenter

          # add sauce job public link to rspec3 failed examples
          def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
            alignment_basis = "#{' ' * @indentation}#{failure_number}) "
            indentation = ' ' * alignment_basis.length
            sauce_link = "\n#{indentation}Sauce public job link: #{@example.metadata[:sauce_public_link]}"

            "\n#{alignment_basis}#{description_and_detail(colorizer, indentation)}" \
            "#{sauce_link}" \
            "\n#{formatted_message_and_backtrace(colorizer, indentation)}" \
            "#{extra_detail_formatter.call(failure_number, colorizer, indentation)}"
          end
        end
      end
    end
  end
rescue LoadError
  # User isn't using RSpec 3
rescue NameError
  # User isn't using RSpec 3
end
