require 'devise_active_directory_authenticatable/strategy'

module Devise
  module Models
    # LDAP Module, responsible for validating the user credentials via LDAP.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module AdUser

      #Remove this before production
      Logger = DeviseActiveDirectoryAuthenticatable::Logger

      extend ActiveSupport::Concern
      
      included do
        #What are these for, why would we need to read them?
        attr_reader :current_password, :password
        #Why do we need to store this?
        attr_accessor :password_confirmation
      end
      
      # Should this exist?  Shouldn't it reset the LDAP password?
      # Why would we be storing the password in plaintext?
      def password=(new_password)
        @password = new_password
      end

      def login_with
        self[::Devise.authentication_keys.first]
      end
      
      #Updates the password in the LDAP
      def reset_password!(new_password, new_password_confirmation)
        if new_password == new_password_confirmation && ::Devise.ldap_update_password
          Devise::ActiveDirectoryAdapter.update_password(login_with, new_password)
        end
        clear_reset_password_token if valid?
        save
      end      

      # Checks if a resource is valid upon authentication.
      def valid_ldap_authentication?(password)
        if Devise::LdapAdapter.valid_credentials?(login_with, password)
          return true
        else
          return false
        end
      end
      
      def ldap_groups
        Devise::ActiveDirectoryAdapter.get_groups(login_with)
      end

      module ClassMethods

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_activedirectory(attributes={}) 
          @login_with = ::Devise.authentication_keys.first

          return nil unless attributes[@login_with].present? 

          username = attributes[@login_with]
          password = attributes[:password]

          ::Devise.ad_settings.merge!({ 
              :auth => {
                :method => :simple,
                :username => username,
                :password => password
              }
            })

          #Connect to AD
          ActiveDirectory::Base.setup(::Devise.ad_settings)

          #Try to find the user in the AD
          user = ActiveDirectory::User.find(:first,
              :userPrincipalName => username)

          raise "Invalid User.  Could not connect with AD." unless user

          #Try to find them in the database
          resource = scoped.where(@login_with => attributes[@login_with]).first

          if resource.blank? and ::Devise.ad_create_user
            resource = create_from_ad(user)
            resource[@login_with] = attributes[@login_with]
          end
          
          if user.guid == resource.guid
            resource.save if resource.new_record?
            return resource
          end

          return nil
          # if resource.try(:valid_ldap_authentication?, attributes[:password])
          #   resource.save if resource.new_record?
          #   return resource
          # else
          #   return nil
          # end
        end


        def create_from_ad(user)
          resource = new
          resource.guid = user.guid
          resource.dn = user.dn
          resource.firstname = user.givenName
          resource.lastname = user.sn
          #resource[@login_with] = attributes[@login_with] 
          return resource
        end
        
        #What is this for?
        def update_with_password(resource)
          puts "UPDATE_WITH_PASSWORD: #{resource.inspect}"
        end
        
      end
    end
  end
end
