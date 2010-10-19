module Sauce
  begin
    require 'spec'
    module RSpec
      class SeleniumExampleGroup < Spec::Example::ExampleGroup
        attr_reader :selenium

        before(:all) do
          @selenium = Sauce::Selenium.new
        end

        before(:each) do
          @selenium.start
        end

        after(:each) do
          @selenium.stop
        end

        alias_method :page, :selenium
        alias_method :s, :selenium

        Spec::Example::ExampleGroupFactory.register(:selenium, self)
      end
    end
  rescue LoadError
    # User doesn't have RSpec installed
  end
end
