require 'devise_active_directory_authenticatable/strategy'
require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/models/ad_object'
require 'devise_active_directory_authenticatable/models/ad_group'

module Devise
  module Models
    # Active Directory Module, responsible for validating the user credentials via Active Directory
    #
    module AdUser
      extend ActiveSupport::Concern
      include AdObject

      Logger = DeviseActiveDirectoryAuthenticatable::Logger

      ## Devise key
      def login_with
        self[::Devise.authentication_keys.first]
      end

      # Login event handler.  Triggered after authentication.
      def login
        activedirectory_sync!

        super if defined? super
      end

      def authenticate_with_activedirectory params = {}
        params[:username] ||= self[login_with]
        set_activedirectory_credentials params
        activedirectory_connect
      end

      module ClassMethods
        def activedirectory_class
          ActiveDirectory::User
        end

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_activedirectory(attributes={}) 
          @login_with = ::Devise.authentication_keys.first

          username = attributes[@login_with]
          password = attributes[:password]

          Logger.send "Attempting to login :#{@login_with} => #{username}"
          set_activedirectory_credentials :username => username, :password => password
          activedirectory_connect
          Logger.send "Attempt Result: #{ActiveDirectory::Base.error}"


          # ad_user = find_in_activedirectory(@login_with => username)
          # return false unless ad_user

          # Find them in the local database
          user = find_or_create_from_activedirectory(@login_with => attributes[@login_with]).first
          Logger.send "User: #{user.inspect}"

          # Check to see if we have the same user
          unless user.nil?
            user.save if user.new_record? and ::Devise.ad_create_user
            user.login if user.respond_to?(:login)
            return user
          else
            raise DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException, "Active Directory user and entry in local database have different GUIDs. Possible database inconsistency."
          end
        end
      end
    end
  end
end
