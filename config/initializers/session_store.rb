# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_aliciaboswell_session',
  :secret      => '11df2263ce09cab20735bd8fcb3e1a8db5bde8732ab95ea207192e95f8f6edcce4f8f66791230ee0129d897ae46ad98d2141e66ff67ca5fbce11f168a0d747dd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
