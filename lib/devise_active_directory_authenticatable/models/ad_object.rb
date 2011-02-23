module Devise
  #Basic functions and shared methods for AD objects in ActiveRecord
  module AdObject
    extend ActiveSupport::Concern

    Logger = DeviseActiveDirectoryAuthenticatable::Logger

    def klass
      self.class
    end

    # Update the attributes of the current object from the AD
    # Defaults to current user if no parameters given
    def activedirectory_sync! params = {}
      params[:objectguid] = self.objectguid if params.empty?
      ad_obj = params[:object] || klass.find_in_activedirectory(params).first
      copy_from_activedirectory ad_obj unless ad_obj.nil?
    end

    # Update the attributes of the current object from the AD
    # Defaults to current user if no parameters given
    def update_from_activedirectory! params = {}
      params[:objectguid] = self.objectguid if params.empty?
      ad_obj = params[:object] || klass.find_in_activedirectory(params).first
      copy_from_activedirectory ad_obj unless ad_obj.nil?
    end

    # Update the local object using an Active Directory entry
    def copy_from_activedirectory ad_obj
      ::Devise.ad_attr_mapping[klass.devise_model_name.to_sym].each do |local_attr, active_directory_attr|
        self[local_attr] = ad_obj.send(active_directory_attr)
      end
    end

    def find_in_activedirectory
      klass.find_in_activedirectory :objectGUID => objectGUID
    end

    module ClassMethods

      def login_with
        ::Devise.authentication_keys.first
      end

      def devise_model_name
        devise_model.name[/.*::(.*)/, 1]
      end

      def activedirectory_class_name
        activedirectory_class.name[/.*::(.*)/, 1]
      end

      #Search based on GUID, DN or Username primarily
      def find_in_activedirectory(local_params = {})
        #Reverse mappings for user
        ad_params = local_attrs_to_ad local_params
        Logger.send "Translated #{local_params.inspect} to #{ad_params.inspect}"
        return find_all_in_activedirectory if ad_params.empty?

        activedirectory_class.find(:all, ad_params)
      end

      def find_or_create_from_activedirectory params = {}
        ad_objs = find_in_activedirectory params
        local_objs = []

        ad_objs.each do |ad_obj|
          obj = scoped.where(:objectguid => ad_obj.objectguid).first
          obj = new if obj.blank?

          obj.activedirectory_sync! :object => ad_obj

          local_objs << obj
        end

        local_objs
      end

      def find_all_in_activedirectory
        activedirectory_class.find(:all)
      end

      def connected_to_activedirectory?
        ActiveDirectory::Base.connected?
      end

      # Initializes connection with active directory
      def set_activedirectory_credentials(params = {})
        #Used for username and password
        ::Devise.ad_settings[:auth].merge! params
      end

      def activedirectory_connect
        ActiveDirectory::Base.setup(::Devise.ad_settings)
        raise DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException, "Invalid Username or Password" unless ActiveDirectory::Base.connected?
      end

      private

      #TODO switch from reverse to rassoc to allow for multiple mappings
      def ad_field_to_local field_name
        @ad_to_local_map ||= ::Devise.ad_attr_mapping[devise_model_name.to_sym].invert
        return (@ad_to_local_map.has_key? field_name) ? @ad_to_local_map[field_name] : field_name
      end

      #TODO switch from reverse to rassoc to allow for multiple mappings
      def local_field_to_ad field_name
        @local_to_ad_map ||= ::Devise.ad_attr_mapping[devise_model_name.to_sym]
        return (@local_to_ad_map.has_key? field_name) ? @local_to_ad_map[field_name] : field_name
      end

      def ad_attrs_to_local ad_attrs
        local_attrs = {}
        ad_attrs.each do |ad_key, value|
          local_key = ad_field_to_local(ad_key)
          local_attrs[local_key] = value
        end
        local_attrs
      end

      def local_attrs_to_ad local_attrs
        ad_attrs = {}
        local_attrs.each do |local_key, value|
          ad_key = local_field_to_ad(local_key)
          ad_attrs[ad_key] = value
        end
        ad_attrs
      end

    end
  end
end