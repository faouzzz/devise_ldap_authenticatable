module DeviseActiveDirectoryAuthenticatable
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    class_option :user_model, :type => :string, :default => "user", :desc => "User model to update"
    class_option :group_model, :type => :string, :default => "group", :desc => "Group model to update"
    class_option :update_model, :type => :boolean, :default => true, :desc => "Update models to change from database_authenticatable to active_directory_authenticatable or insert the code"
    class_option :add_rescue, :type => :boolean, :default => true, :desc => "Update Application Controller with resuce_from for DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException"
    
    
    def create_default_devise_settings
      inject_into_file "config/initializers/devise.rb", default_devise_settings, :after => "Devise.setup do |config|\n"   
    end
    
    def update_user_model
      gsub_file "app/models/#{options.user_model}.rb", /:database_authenticatable/, ":ad_user" if options.update_model?
    end

    def update_group_model
      inject_into_class "app/models/#{options.group_model}.rb", options.group_model, "devise :ad_group" if options.update_model?
    end
    
    def update_application_controller
      inject_into_class "app/controllers/application_controller.rb", ApplicationController, rescue_from_exception if options.add_rescue?
    end
    
    private
    
    def default_devise_settings
      settings = <<-eof
  # ==> Basic Active Directory Configuration 
  
  ## Active Directory server settings
  # config.ad_settings = {
  #   :host => 'domain-controller.example.local',
  #   :base => 'dc=example,dc=local',
  #   :port => 636,
  #   :encryption => :simple_tls,
  #   :auth => {
  #     :method => :simple
  #   }
  # }


  # config.ad_attr_mapping = {
  ##Attribute mapping for user object
  #   :AdUser => {
  #     #Attributes are lowercase
  #     :objectguid => :objectguid, #Required
  #     :username => :userprincipalname,
  #     :dn => :dn,
  #     :firstname => :givenName,
  #     :lastname => :sn,
  #     :whenchanged => :whenchanged,
  #     :whencreated => :whencreated,
  #   },

  ##Attribute mapping for group objects
  #   :AdGroup => {
  #     #Attributes are lowercase
  #     :objectguid => :objectguid, #Required
  #     :dn => :dn,
  #     :name => :name,
  #     :description => :description,
  #     :whencreated => :whencreated,
  #     :whenchanged => :whenchanged,
  #   }
  # }


  ##Username attribute
  ##Maps to :login_with in the devise configuration
  # config.ad_username = :userPrincipalName

  ##Create the user if they're not found
  ##If this is false, you will need to create the user object before they will be allowed to login
  # config.ad_create_user = true

  ##Log LDAP queries to the Rails logger
  # config.ad_logger = true

  ##Update the user object from the AD
  # config.ad_update_users = true

  ##Update the group object from the AD
  # config.ad_update_groups = true

  ##Update the group memberships from the AD, this uses the ancestory gem to store the hierarchy
  # config.ad_update_group_memberships = true

  ##Update the user memberships from the AD
  # config.ad_update_user_memberships = true

        eof
      
      settings
    end
    
    def rescue_from_exception
      <<-eof
  rescue_from DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException do |exception|
    render :text => exception, :status => 500
  end
      eof
    end
    
  end
end
