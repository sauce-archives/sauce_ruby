module Sauce
  if ENV['SAUCE_ONDEMAND_HEROKU_URL'] and ENV['URL']

    # Heroku Configuation
    config                   = JSON.parse RestClient.get(ENV['SAUCE_ONDEMAND_HEROKU_URL']).body
    Sauce::Selenium_browsers = JSON.parse config["SAUCE_ONDEMAND_BROWSERS"]
    Sauce::Selenium_url      =            "#{config['SAUCE_ONDEMAND_PROTOCOL']}#{ENV['URL']}"
    Sauce::Selenium_host     =            config["SAUCE_ONDEMAND_SERVER"  ]
    Sauce::Selenium_port     =            config["SAUCE_ONDEMAND_PORT"    ]
  else
    
    # Local Configuration
    Sauce::Selenium_url      = ENV['SELENIUM_URL']     || "http://localhost:3000"
    Sauce::Selenium_host     = ENV['SELENIUM_HOST']    || "localhost"
    Sauce::Selenium_port     = ENV['SELENIUM_PORT']    || "4444"
    Sauce::Selenium_browsers = ENV['SELENIUM_BROWSER'] || ["*firefox"]
  end
end
