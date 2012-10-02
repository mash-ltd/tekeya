module Tekeya
  module Feed
    module Attachement
      extend ActiveSupport::Concern

      included do
        belongs_to :activity, polymorphic: true
      end

      module ClassMethods
      end

    end
  end
end