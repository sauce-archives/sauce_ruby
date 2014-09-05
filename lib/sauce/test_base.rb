module Sauce
  module TestBase

    # Run a block with every platform
    def test_each(platforms, description)
      platforms.each do |platform|
        capabilities = {
          :os => platform[0],
          :browser => platform[1],
          :browser_version => platform[2],
          :job_name => description
        }

        capabilities.merge! platform[3] if platform[3]
        selenium = Sauce::Selenium2.new(capabilities)

        yield selenium, capabilities
      end
    end
  end
end