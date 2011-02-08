# encoding: utf-8
require 'devise'
require 'active_directory'

require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/logger'

# Get ldap information from config/ldap.yml now
module Devise

  ##TODO Revise these options/vars and their corresponding generator

  #Active Directory settings
  mattr_accessor :ad_settings
  @@ad_settings = {
    :host => 'domain-controller.example.local',
    :base => 'dc=example,dc=local',
    :port => 389,
    :auth => {
      :method => :simple
    }
  }

  #Attribute mapping for user object
  mattr_accessor :ad_attr_mapping
  @@ad_attr_mapping = {
    :objectGUID => :objectGUID, #Required
    :username => :userPrincipalName,
    :dn => :dn,
    :firstname => :givenName,
    :lastname => :sn,
  }

  #Username attribute
  mattr_accessor :ad_username
  @@ad_username = :userPrincipalName

  #Create the user if they're not found
  mattr_accessor :ad_create_user
  @@ad_create_user = true

  # Log LDAP queries to the Rails logger
  mattr_accessor :ad_logger
  @@ad_logger = true
end

# Add ldap_authenticatable strategy to defaults.
#
Devise.add_module(:ad_user,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_active_directory_authenticatable/model')
