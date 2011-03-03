require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/models/ad_object'

module Devise
  module Models
    # Active Directory Module, responsible for validating the user credentials via Active Directory
    #
    module AdGroup
      extend ActiveSupport::Concern
      include AdObject

      def validate_memberships repair=true
      end

      def sync_group_memberships
        return falses unless ::Devise.ad_update_group_memberships

        #Grab AD Memberships for the current object

        #Sync them

      end

      #Remember to check for cycles in the graph
      #BFS or DFS?
      def find_all_parents
      end

      #Remember to check for cycles in the graph
      #BFS or DFS?
      def find_all_members type = :all
        case type
          when :all

          when :users

          when :groups

          else
            throw "Invalid argument"
        end
      end




      #Perhaps build a translation layer for the current way attributes are synced

      module ClassMethods
        # TODO find a way to get rid of this with metaprogramming
        def devise_model
          AdGroup
        end

        def activedirectory_class
          ActiveDirectory::Group
        end

        def sync_all
          return false unless connected_to_activedirectory?

          groups = find_or_create_from_activedirectory
          # self.class.import groups
          ActiveRecord::Base.transaction do
            groups.each { |gp| gp.save if gp.new_record? }
            groups.each do |gp| 
              gp.update_memberships
              gp.save
            end
          end
        end

        def sync_group_memberships
          return false unless ::Devise.ad_update_group_memberships

          #Grab all groups and their corresponding AD objects

          #Iterate through each one and upate the memberships

        end

        #Validate the group memberships graph
        def validate_memberships repair=true
        end
      end

    end
  end
end
