Devise Active Directory Authenticatable
===========================

Devise ActiveDirectory Authenticatable is a AD based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use AD, this plugin is for you.

Please note, this plugin is currently under heavy development.

Requirements
------------

- An Active Directory server (tested on Server 2008)
- Rails 3.0.0

These gems are dependencies of the gem:

- Devise 1.1.5
- active_directory 1.2.4
- activerecord-import 0.2.0

Installation
------------

**_Please Note_**

This will *only* work for Rails 3 applications.

In the Gemfile for your application:

    gem "devise"
    gem "devise_active_directory_authenticatable"


Setup
-----

Run the rails generators for devise (please check the [devise](http://github.com/plataformatec/devise) documents for further instructions)

    rails generate devise:install
    rails generate devise MODEL_NAME

Run the rails generator for devise_active_directory_authenticatable

    rails generate devise_active_directory_authenticatable:install [options]

This will update the devise.rb initializer, and update your user model. There are some options you can pass to it:

Options:

    [--user-model=USER_MODEL]  # User Model to update
                               # Default: user
    [--group-model=USER_MODEL] # Group Model to update
                               # Default: group
    [--add-rescue]             # Update Application Controller with resuce_from for DeviseActiveDirectoryAuthenticatable::ActiveDirectoryException
                               # Default: true

The rest of this documentation needs to be revised.  To get going on this, run the installer which will add some configuration options to config/intializers/devise.rb

Update your user and group tables in the database with migrations.  Check attributes that are set in config/initializers/devise.rb to see which ones you will have to add.

In your user model add:

    devise :ad_user

In your group model add:

    devise :ad_group
    

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
  * Attribute mapping between active directory and the user model.  These attributes will be pulled from the AD

* ad\_username _(default: :userPrincipalName)_
  * Username attribute on the AD to login with.  Maps with the login_with attribute from devise.

* ad\_create\_user _(default: true)_
  * If set to true, all valid Active Directory users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.

* ad\_logger _(default: true)_
  * If set to true, will log Active Directory queries to the Rails logger.

* ad\_update\_users _(default: true)_
  * If true, devise will update the user attributes from the Active Directory when the user logs in

* ad\_update\_groups _(default: true)_
  * If true, devise will allow the group models to be update from the Active Directory

* ad\_update\_group\_memberships _(default: true)_ _[unimplemented]_
  * If true, devise will allow the memberships for groups and users to be updated.  It will also update the memberships when a user logs in.

* ad\_update\_user\_memberships _(default: true)_ _[unimplemented]_
  * If true, devise will allow the memberships for groups and users to be updated.  It will also update the memberships when a user logs in.

* ad\_caching _(default: true)_
  * If true, this will instruct the plugin to use the active_directory caching feature.  This greatly speeds up queries that are using the distinguishedname such as querying for group and user memberships.


References
----------

* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)

