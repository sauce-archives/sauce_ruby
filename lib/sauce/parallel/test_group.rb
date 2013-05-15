module Sauce
  class TestGroup
    def initialize(platforms)
      @platforms = platforms
      @index = 0
    end

    def next_platform
      platform = @platforms[@index]
      begin
        @index = @index + 1
        {
          :SAUCE_OS => "'#{platform[0]}'",
          :SAUCE_BROWSER => "'#{platform[1]}'",
          :SAUCE_BROWSER_VERSION => "'#{platform[2]}'"
        }
      rescue NoMethodError => e
        puts "I don't have any config"
      end
    end
  end
end
