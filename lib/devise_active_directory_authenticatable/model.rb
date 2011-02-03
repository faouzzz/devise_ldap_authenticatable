require 'devise_ldap_authenticatable/strategy'

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
      extend ActiveSupport::Concern
      
      included do
        #What are these for, why would we need to read them?
        attr_reader :current_password, :password
        #Why do we need to store this?
        attr_accessor :password_confirmation
        attr_reader :dn
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
        def authenticate_with_ldap(attributes={}) 
          @login_with = ::Devise.authentication_keys.first
          return nil unless attributes[@login_with].present? 

          # resource = find_for_ldap_authentication(conditions)
          resource = scoped.where(@login_with => attributes[@login_with]).first
                    
          if (resource.blank? and ::Devise.ldap_create_user)
            resource = new
            resource[@login_with] = attributes[@login_with]            
          end
                    
          if resource.try(:valid_ldap_authentication?, attributes[:password])
            resource.save if resource.new_record?
            return resource
          else
            return nil
          end
        end
        
        #What is this for?
        def update_with_password(resource)
          puts "UPDATE_WITH_PASSWORD: #{resource.inspect}"
        end
        
      end
    end
  end
end
