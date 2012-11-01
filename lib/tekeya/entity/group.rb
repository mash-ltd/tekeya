module Tekeya
  module Entity
    module Group
      extend ActiveSupport::Concern
      include Entity

      included do
        belongs_to :owner, polymorphic: true

        validates_presence_of :owner
      end

      def is_tekeya_group?
        return true
      end

      def members(type = nil)
        tekeya_relations_of(self, :joins, type, true)
      end
    end
  end
end