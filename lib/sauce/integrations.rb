begin
  require 'spec'
  module Sauce
    module RSpec
      class SeleniumExampleGroup < Spec::Example::ExampleGroup
        attr_reader :selenium

        before(:each) do
          @selenium.start
        end

        after(:each) do
          @selenium.stop
        end

        def execute(*args)
          config = Sauce::Config.new
          description = [self.class.description, self.description].join(" ")
          config.browsers.each do |os, browser, version|
            @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
              :job_name => "#{description}"})
            super(*args)
          end
        end

        alias_method :page, :selenium
        alias_method :s, :selenium

        Spec::Example::ExampleGroupFactory.register(:selenium, self)
      end
    end
  end
rescue LoadError
  # User doesn't have RSpec installed
end
