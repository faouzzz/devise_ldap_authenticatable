require 'devise_active_directory_authenticatable/strategy'
require 'devise_active_directory_authenticatable/exception'

module Devise
  module Models
    # LDAP Module, responsible for validating the user credentials via LDAP.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    # By convention guid is human readable hex encoding
    # objectGUID is binary encoding madness
    module AdUser

      #Remove this before production
      ADConnect = DeviseActiveDirectoryAuthenticatable
      ADUser = ActiveDirectory::User
      Logger = DeviseActiveDirectoryAuthenticatable::Logger

      extend ActiveSupport::Concern


      def login_with
        self[::Devise.authentication_keys.first]
      end

      def objectGuid
        guid.to_a.pack("H*")
      end
      
      #Updates the password in the LDAP
      def reset_password!(new_password, new_password_confirmation)
        # if new_password == new_password_confirmation && ::Devise.ldap_update_password
        #   Devise::ActiveDirectoryAdapter.update_password(login_with, new_password)
        # end
        # clear_reset_password_token if valid?
        # save
      end


      #Store attributes
      def update_from_activedirectory(params = {})
        params[:guid] = self.guid if params.empty?
        params[:user] ||= User.find_in_activedirectory(params)
        user = params[:user]

        return false if user.nil?

        Logger.send "Updating #{params.inspect}"

        ::Devise.ad_attr_mapping.each do |user_attr, active_directory_attr|
          self[user_attr] = user.send(active_directory_attr)
        end
      end

      def login
        update_from_activedirectory
        super if defined? super 
      end


      module ClassMethods

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_activedirectory(attributes={}) 
          @login_with = ::Devise.authentication_keys.first

          raise ADConnect::ActiveDirectoryException, "Annonymous binds are not permitted." unless attributes[@login_with].present?

          username = attributes[@login_with]
          password = attributes[:password]

          Logger.send "Attempting to login :#{@login_with} => #{username}"

          ad_connect(:username => username, :password => password)

          #Try to find the user in the AD
          user = find_in_activedirectory(:username => username)
          
          Logger.send "Attempt Result: #{ActiveDirectory::Base.error}"
          raise ADConnect::ActiveDirectoryException, "Could not connect with Active Directory.  Check your username, password, and ensure that your account is not locked." unless user

          #Try to find them in the database
          resource = scoped.where(@login_with => attributes[@login_with]).first

          if resource.blank? and ::Devise.ad_create_user
            Logger.send "Creating new user in database"

            resource = new
            resource.update_from_activedirectory(:user => user)
            resource[@login_with] = attributes[@login_with]
            Logger.send "Created: #{resource.inspect}"
          end
          
          Logger.send "Checking [#{user.guid.inspect}] == [#{resource.guid.inspect}]"

          # Check to see if we have the same user
          if user.guid.first == resource.guid
            resource.save if resource.new_record?

            Logger.send "Trigging login handler for #{username}"
            resource.login if resource.respond_to?(:login)
            return resource
          else
            raise ADConnect::ActiveDirectoryException, "Invalid Username or Password.  Possible database inconsistency."
          end
        end

        #Search based on GUID, DN or Username primarily
        def find_in_activedirectory(params = {})
          #Reverse the mappings
          params[::Devise.ad_username] ||= params[:username] if params[:username].present?
          params[::Devise.ad_username] ||= params[@login_with] if params[@login_with].present?
          params[:objectGUID] ||= params[:guid].to_a.pack("H*") if params[:guid].present?

          params.delete(:guid)
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
