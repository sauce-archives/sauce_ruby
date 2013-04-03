module Sauce
  def self.driver_pool
    @@driver_pool ||= {}
  end
end
