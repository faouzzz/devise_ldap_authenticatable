# encoding: utf-8
require 'devise'

require 'devise_ldap_authenticatable/exception'
require 'devise_ldap_authenticatable/logger'
require 'devise_ldap_authenticatable/schema'
require 'devise_ldap_authenticatable/ldap_adapter'
require 'devise_ldap_authenticatable/routes'

# Get ldap information from config/ldap.yml now
module Devise
  # Log LDAP queries to the Rails logger
  mattr_accessor :ldap_logger
  @@ldap_logger = true
  
  # If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created. 
  # If set to false, you will have to create the user record before they will be allowed to login.
  mattr_accessor :ldap_create_user
  @@ldap_create_user = false
  
  # Location of LDAP configuration file
  mattr_accessor :ldap_config
  # @@ldap_config = "#{Rails.root}/config/ldap.yml"
  
  # Allow Devise to update the user's password in LDAP
  # Requires the admin username/password to be set in the config file
  mattr_accessor :ldap_update_password
  @@ldap_update_password = true
  
  # Requires that users be a member of specific groups as specified in the config file
  # This is not the same as active directory memberships, it uses the CNs and OUs
  mattr_accessor :ldap_check_group_membership
  @@ldap_check_group_membership = false
  
  # Require that users have a specific attribute set in the LDAP.
  # The required attributes and their values are stored in the configuration file
  mattr_accessor :ldap_check_attributes
  @@ldap_check_role_attribute = false
  
  # Use the admin credentials in the configuration file to bind agains the LDAP server before authenticating the user
  mattr_accessor :ldap_use_admin_to_bind
  @@ldap_use_admin_to_bind = false
  
  # You can pass a proc to the username option to explicitly specify the format that you search for a users' DN on your LDAP server
  mattr_accessor :ldap_auth_username_builder
  @@ldap_auth_username_builder = Proc.new() {|attribute, login, ldap| "#{attribute}=#{login},#{ldap.base}" }
end

# Add ldap_authenticatable strategy to defaults.
#
Devise.add_module(:ldap_authenticatable,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_ldap_authenticatable/model')
