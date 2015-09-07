require "sauce/logging"

module Sauce
  class TestGroup
    def initialize(platforms)
      @platforms = platforms
      @index = 0
    end

    def next_platform
      platform = @platforms[@index]
      @index += 1
      begin
        caps ={
          'os' => platform[0],
          'browser' => platform[1],
          'version' => platform[2]
        }
        caps.merge!({:caps => platform[3]}) if platform[3]
        caps
      rescue NoMethodError
        puts "I don't have any config"
      end
    end
  end
end
