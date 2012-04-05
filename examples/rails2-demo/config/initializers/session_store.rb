# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails2-demo_session',
  :secret      => '2f905ec35f3ceaf22b9c6728bf1871e261cafa346c15f3567e55ceca5625abac89ccbc5fe17f42d097f23ba1cf27b5cd8e0e0bc9532abfe3d4e14b5a35acc1e5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
