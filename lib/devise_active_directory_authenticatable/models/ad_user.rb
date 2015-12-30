require 'devise_active_directory_authenticatable/strategy'
require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/models/ad_object'

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
      # Maybe
      # def login
      #   update_parents
      #   super if defined? super
      # end

      def authenticate_with_activedirectory params = {}
        params[:username] ||= login_with
        self.class.set_activedirectory_credentials params
        self.class.activedirectory_connect
      end

      module ClassMethods
        # TODO find a way to get rid of this with metaprogramming
        def devise_model
          AdUser
        end

        def activedirectory_class
          ActiveDirectory::User
        end

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_activedirectory(attributes={})
          domain = attributes[:domain]
          username = "#{domain}\\#{attributes[login_with]}"
          password = attributes[:password]

          Logger.send "Attempting to login :#{@login_with} => #{username}"
          set_activedirectory_credentials  :domain => domain, auth: {:username => username, :password => password}
          connected = activedirectory_connect
          Logger.send "Attempt Result: #{ActiveDirectory::Base.error}"
          return :invalid unless connected

          # Find them in the local database
          user = find_or_create_from_activedirectory(login_with => attributes[login_with]).first

          # Check to see if we have the same user
          unless user.nil?
            return :no_email unless user.email.present?
            user.domain = domain
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
