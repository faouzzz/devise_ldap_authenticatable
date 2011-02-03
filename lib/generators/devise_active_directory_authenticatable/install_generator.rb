module DeviseLdapAuthenticatable
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    class_option :user_model, :type => :string, :default => "user", :desc => "Model to update"
    class_option :update_model, :type => :boolean, :default => true, :desc => "Update model to change from database_authenticatable to ldap_authenticatable"
    class_option :add_rescue, :type => :boolean, :default => true, :desc => "Update Application Controller with resuce_from for DeviseLdapAuthenticatable::LdapException"
    class_option :advanced, :type => :boolean, :desc => "Add advanced config options to the devise initializer"
    
    
    def create_ldap_config
      copy_file "ldap.yml", "config/ldap.yml"
    end
    
    def create_default_devise_settings
      inject_into_file "config/initializers/devise.rb", default_devise_settings, :after => "Devise.setup do |config|\n"   
    end
    
    def update_user_model
      gsub_file "app/models/#{options.user_model}.rb", /:database_authenticatable/, ":ldap_authenticatable" if options.update_model?
    end
    
    def update_application_controller
      inject_into_class "app/controllers/application_controller.rb", ApplicationController, rescue_from_exception if options.add_rescue?
    end
    
    private
    
    def default_devise_settings
      settings = <<-eof
  # ==> Basic LDAP Configuration 
  # Log LDAP queries to the Rails logger
  # config.ldap_logger = true
  # 
  # If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created. 
  # If set to false, you will have to create the user record before they will be allowed to login.
  # config.ldap_create_user = false
  #
  # Allow Devise to update the user's password in LDAP
  # Requires the admin username/password to be set in the config file
  # config.ldap_update_password = true
  #
  # LDAP Configuration file location
  # config.ldap_config = "\#{Rails.root}/config/ldap.yml"
  #
  # Require users to belong to the groups/OUs
  # The groups are set in the configuration file
  # This is different than Active Directory group membership
  # config.ldap_check_group_membership = false
  #  
  # Requires that users be a member of specific groups as specified in the config file
  # This is not the same as active directory memberships, it uses the CNs and OUs
  # config.ldap_check_attributes = false
  #
  # Use the admin credentials in the configuration file to bind agains the LDAP server before authenticating the user
  # config.ldap_use_admin_to_bind = false
  #
  # ==> Advanced LDAP Configuration
  # You can pass a proc to the username option to explicitly specify the format that you search for a users' DN on your LDAP server
  # config.ldap_auth_username_builder = Proc.new() {|attribute, login, ldap| "\#{attribute}=\#{login},\#{ldap.base}" }

        eof
      end
      
      settings
    end
    
    def rescue_from_exception
      <<-eof
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
      eof
    end
    
  end
end
