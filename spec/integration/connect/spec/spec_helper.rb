require "sauce"
require "sauce/connect"

Sauce.config do |c|
  c[:start_tunnel] = true
end