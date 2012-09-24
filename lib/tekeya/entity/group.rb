module Tekeya
  module Entity
    module Group
      extend ActiveSupport::Concern

      included do
        self.send :extend, ::Tekeya::Entity
      end

      module ClassMethods
      end

      def members(type = nil)
        relations_of(type, :tracks, self)
      end
    end
  end
end