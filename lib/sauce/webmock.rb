require 'webmock/config'

config = WebMock::Config.instance

unless config.allow_net_connect
  allow_localhost = config.allow_localhost
  allow = config.allow || []
  allow << /saucelabs.com/
  connect_on_start = config.net_http_connect_on_start

  WebMock.disable_net_connect!(
    :allow_localhost => allow_localhost,
    :allow => allow, 
    :net_http_connect_on_start => connect_on_start
  )
end