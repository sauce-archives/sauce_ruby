require "sauce"

Sauce.config do |c|
  c[:browsers] = [
      ["Windows 7", "Opera", 10],
      ["Linux", "Firefox", 19]
  ]
end