require "net/ldap"

module Devise
  module LDAP
    DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY = 'uniqueMember'

    module Adapter
      def self.valid_credentials?(domain, login, password_plaintext)
        options = {domain: domain, :login => login,
                   :password => password_plaintext,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.authorized?
      end

      def self.update_password(domain, login, new_password)
        options = {domain: domain, :login => login,
                   :new_password => new_password,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.change_password! if new_password.present?
      end

      def self.update_own_password(login, new_password, current_password)
        set_ldap_param(login, :userPassword, ::Devise.ldap_auth_password_builder.call(new_password), current_password)
      end

      def self.ldap_connect(domain, login)
        options = {domain: domain, :login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
      end

      def self.valid_login?(domain, login)
        self.ldap_connect(domain, login).valid_login?
      end

      def self.get_groups(domain, login)
        self.ldap_connect(domain, login).user_groups
      end

      def self.in_ldap_group?(domain, login, group_name, group_attribute = nil)
        self.ldap_connect(domain, login).in_group?(group_name, group_attribute)
      end

      def self.get_dn(domain, login)
        self.ldap_connect(domain, login).dn
      end

      def self.set_ldap_param(domain, login, param, new_value, password = nil)
        options = { domain: domain, :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(param, new_value)
      end

      def self.delete_ldap_param(domain, login, param, password = nil)
        options = { domain: domain, :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.delete_param(param)
      end

      def self.get_ldap_param(domain, login,param)
        resource = self.ldap_connect(domain, login)
        resource.ldap_param_value(param)
      end

      def self.get_ldap_entry(domain, login)
        self.ldap_connect(domain, login).search_for_login
      end

    end

  end

end
