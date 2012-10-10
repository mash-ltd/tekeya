module Tekeya
  module Entity
    module Group
      extend ActiveSupport::Concern
      include Entity

      included do
      end

      module ClassMethods
      end

      def is_tekeya_group?
        return true
      end

      def members(type = nil)
        relations_of(self, :joins, type, true)
      end
    end
  end
end