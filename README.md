Devise Active Directory Authenticatable
===========================

Devise ActiveDirectory Authenticatable is a AD based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use AD, this plugin is for you.

Requirements
------------

- An Active Directory server (tested on Server 2008)
- Rails 3.0.0

These gems are dependencies of the gem:

- Devise 1.1.2
- active_directory 1.0.4 from http://github.com/ajrkerr/activedirectory

Installation
------------

**_Please Note_**

This will *only* work for Rails 3 applications.

In the Gemfile for your application:

    gem "devise", ">=1.1.2"
    gem "devise_active_directory_authenticatable"
    
To get the latest version, pull directly from github instead of the gem:

    gem "devise_active_directory_authenticatable", :git => "git://github.com/ajrkerr/devise_active_directory_authenticatable.git"


Setup
-----

Run the rails generators for devise (please check the [devise](http://github.com/plataformatec/devise) documents for further instructions)

    rails generate devise:install
    rails generate devise MODEL_NAME

Run the rails generator for devise_active_directory_authenticatable

    rails generate devise_active_directory_authenticatable:install [options]

This will update the devise.rb initializer, and update your user model. There are some options you can pass to it:

Options:

    [--user-model=USER_MODEL]  # Model to update
                               # Default: user
    [--add-rescue]             # Update Application Controller with resuce_from for DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException
                               # Default: true


Usage
-----

**_Please Note_**

This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.

The field that is used for logins is the first key that's configured in the `config/devise.rb` file under `config.authentication_keys`, which by default is email. For help changing this, please see the [Railscast](http://railscasts.com/episodes/210-customizing-devise) that goes through how to customize Devise.

Configuration
-------------

In initializer  `config/initializers/devise.rb` :

* ad\_settigns
  * Active Directory server configuration settings

* ad\_attr\_mapping 
  * Attribute mapping between active directory and the user model

* ad\_username _(default: :userPrincipalName)_
  * Username attribute on the AD to login with.  Maps with the login_with attribute from devise.

* ad\_create\_user _(default: true)_
  * If set to true, all valid Active Directory users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.

* ad\_logger _(default: true)_
  * If set to true, will log Active Directory queries to the Rails logger.


References
----------

* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)

