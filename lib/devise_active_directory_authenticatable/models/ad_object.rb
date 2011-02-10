module Devise
  module Models

    #Basic functions and shared methods for AD objects in ActiveRecord
    module AdObject

      ADConnect = DeviseActiveDirectoryAuthenticatable
      Logger = DeviseActiveDirectoryAuthenticatable::Logger

      extend ActiveSupport::Concern

      included do 
        #Serialize all binary fields
        # ::Devise.ad_special_fields[:binary].each do |field|
        #   serialize field
        # end
      end

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


      module ClassMethods

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
