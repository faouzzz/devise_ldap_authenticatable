require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/models/ad_object'

module Devise
  module Models
    # Active Directory Module, responsible for validating the user credentials via Active Directory
    #
    module AdGroup
      extend ActiveSupport::Concern
      include AdObject

      module ClassMethods
        def activedirectory_class
          ActiveDirectory::Group
        end

        def sync_all
          #return false unless connected_to_activedirectory?
          find_or_create_from_activedirectory.each do |gp|
            gp.save
          end
        end
      end

    end
  end
end
