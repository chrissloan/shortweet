# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_shortweet_session',
  :secret      => 'ce83b9f3061316d50cde51e0f4463ecb5c78f945adb920feec3428f60656d704681f79d06ab8d0ffb6101887ec5f90b008b5b01387b53a03b7e075779b17a65c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
