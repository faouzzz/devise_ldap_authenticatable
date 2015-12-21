# encoding: utf-8
require 'devise'
require 'active_directory'
require 'active_record'

require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/logger'

# Get ldap information from config/ldap.yml now
module Devise

  #Active Directory settings
  mattr_accessor :ad_settings
  @@ad_settings = {
    :host => 'domain-controller.example.local',
    :base => 'dc=example,dc=local',
    :port => 636,
    :encryption => :simple_tls,
    :auth => {
      :method => :simple
    }
  }

  #Attribute mapping for AD to Rails objects
  # :object => { :rails_attr => :ad_attr }
  mattr_accessor :ad_attr_mapping
  @@ad_attr_mapping = {
    #Attribute mapping for user object
    :AdUser => {
      #Attributes are lowercase
      :objectguid => :objectguid, #Required
      :username => :userprincipalname,
      :dn => :dn,
      :firstname => :givenName,
      :lastname => :sn,
      :whenchanged => :whenchanged,
      :whencreated => :whencreated,
    },

    #Attribute mapping for group objects
    :AdGroup => {
      #Attributes are lowercase
      :objectguid => :objectguid, #Required
      :dn => :dn,
      :name => :name,
      :description => :description,
      :whencreated => :whencreated,
      :whenchanged => :whenchanged,
    }
  }

  #Username attribute used for logging in
  #Will be automagicaly mapped to authentication_keys.first
  mattr_accessor :ad_username
  @@ad_username = :userprincipalname

  #Map Devise authentication key accordingly
  #Does this work when initializers are set too?
  @@ad_attr_mapping[:AdUser][::Devise.authentication_keys.first] = @@ad_username

  #Create the user if they're not found
  mattr_accessor :ad_create_user
  @@ad_create_user = true

  # Log LDAP queries to the Rails logger
  mattr_accessor :ad_logger
  @@ad_logger = true

  ##Update the user object from the AD
  mattr_accessor :ad_update_users
  @@ad_update_users = true

  ##Update the group object from the AD
  mattr_accessor :ad_update_groups
  @@ad_update_groups = true

  ##Update the group memberships from the AD, this uses the ancestory gem
  mattr_accessor :ad_update_group_memberships
  @@ad_update_group_memberships = true

  ##Update the user memberships from the AD
  mattr_accessor :ad_update_user_memberships
  @@ad_update_user_memberships = true

  ##Enable Active Directory caching.  This speeds up group/membership queries significantly.
  mattr_accessor :ad_caching
  @@ad_caching = true
end

# Add active_directory_authenticatable strategy to defaults.
#
Devise.add_module(:ad_user,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_active_directory_authenticatable/models/ad_user')

Devise.add_module(:ad_group,
                  :model => 'devise_active_directory_authenticatable/models/ad_group')
