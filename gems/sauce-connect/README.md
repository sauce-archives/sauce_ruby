# Sauce::Connect

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'sauce-connect'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sauce-connect

## Usage
### Mandatory steps for all usecases
```ruby
require "sauce/connect"

Sauce.config do |c|
  # Set a Sauce Connect executable location
  c[:sauce_connect_4_executable] = "/users/you/Downloads/sauce_connect_directory/bin/sc"
  c[:start_tunnel] = true
end
```

### Brute-force a tunnel
To open a tunnel, regardless of another being open, which will close when your Ruby process exits:

```ruby
Sauce::Connect.connect!
```

To block until a tunnel is open, and brute-force one if no tunnel exists:
```ruby
Sauce::Connect.ensure_connected
```

### Manage a tunnel life-cycle manually
#### Creating & starting a tunnel object
```ruby
tunnel = Sauce::Connect.new options
tunnel.connect
```

Valid options are `:quiet`, to suppress tunnel output, and `:timeout`, the number of seconds to try before opening a tunnel.

#### Waiting for tunnel to be ready before starting tests
```ruby
tunnel.wait_until_ready # Throws exceptions once connection timeout is reached
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
