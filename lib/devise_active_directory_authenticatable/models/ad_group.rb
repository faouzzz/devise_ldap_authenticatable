require 'devise_active_directory_authenticatable/strategy'
require 'devise_active_directory_authenticatable/exception'

module Devise
  module Models
    # Active Directory Module, responsible for validating the user credentials via Active Directory
    #
    module AdGroup

      #Remove this before production
      ADConnect = DeviseActiveDirectoryAuthenticatable
      ADUser = ActiveDirectory::User
      Logger = DeviseActiveDirectoryAuthenticatable::Logger

      extend ActiveSupport::Concern

      ## Devise key
      def login_with
        self[::Devise.authentication_keys.first]
      end

      # Update the attributes of the current object from the AD
      # Defaults to current user if no parameters given
      def sync_with_activedirectory(params = {})
        params[:objectGUID] = self.objectGUID if params.empty?
        user = params[:user] || User.find_in_activedirectory(params)

        return false if user.nil?

        Logger.send "Updating #{params.inspect}"

        #Grab attributes from Devise mapping
        ::Devise.ad_attr_mapping.each do |user_attr, active_directory_attr|
          self[user_attr] = user.send(active_directory_attr)
        end
      end

      # Login event handler.  Triggered after authentication.
      def login
        sync_with_activedirectory
        super if defined? super 
      end


      module ClassMethods

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_activedirectory(attributes={}) 
          @login_with = ::Devise.authentication_keys.first

          username = attributes[@login_with]
          password = attributes[:password]

          raise ADConnect::ActiveDirectoryException, "Annonymous binds are not permitted." unless attributes[@login_with].present?

          Logger.send "Attempting to login :#{@login_with} => #{username}"
          ad_connect(:username => username, :password => password)
          ad_user = find_in_activedirectory(:username => username)
          Logger.send "Attempt Result: #{ActiveDirectory::Base.error}"

          raise ADConnect::ActiveDirectoryException, "Could not connect with Active Directory.  Check your username, password, and ensure that your account is not locked." unless ad_user

          # Find them in the local database
          user = scoped.where(@login_with => attributes[@login_with]).first

          if user.blank? and ::Devise.ad_create_user
            Logger.send "Creating new user in database"
            user = new
            user[@login_with] = attributes[@login_with]
            user.sync_with_activedirectory(:user => ad_user)
            Logger.send "Created: #{user.inspect}"
          end
          
          Logger.send "Checking: #{ad_user.objectGUID} == #{user.objectGUID}"
          # Check to see if we have the same user
          if ad_user == user
            user.save if user.new_record?
            user.login if user.respond_to?(:login)
            return user
          else
            raise ADConnect::ActiveDirectoryException, "Invalid Username or Password.  Possible database inconsistency."
          end

        end

        #Search based on GUID, DN or Username primarily
        def find_in_activedirectory(params = {})
          
          #Reverse mappings
          params[::Devise.ad_username] ||= params[:username] if params[:username].present?
          params[::Devise.ad_username] ||= params[@login_with] if params[@login_with].present?

          params.delete(:username)
          params.delete(@login_with)

          Logger.send "Searching for #{params.inspect}"
          user = ADUser.find(:first, params)
          Logger.send "Found: #{user}"

          return user
        end

        private

        def ad_connect(params = {})
          #Used for username and password
          ::Devise.ad_settings[:auth].merge! params

          ActiveDirectory::Base.setup(::Devise.ad_settings)
          Logger.send "Connection Result: #{ActiveDirectory::Base.error}"
        end 
      end
    end
  end
end
