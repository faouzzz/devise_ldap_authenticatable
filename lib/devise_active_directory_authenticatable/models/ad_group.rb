require 'devise_active_directory_authenticatable/exception'
require 'devise_active_directory_authenticatable/models/ad_object'

module Devise
  module Models
    # Active Directory Module, responsible for validating the user credentials via Active Directory
    #
    module AdGroup
      extend ActiveSupport::Concern
      include AdObject

      #Remember to check for cycles in the graph
      #BFS or DFS?
      def find_all_parents
      end

      def find_all_children
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
      end

    end
  end
end
