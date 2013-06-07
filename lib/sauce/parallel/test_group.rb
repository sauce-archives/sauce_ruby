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
        {
          'os' => platform[0],
          'browser' => platform[1],
          'version' => platform[2]
        }
      rescue NoMethodError => e
        puts "I don't have any config"
      end
    end
  end
end
