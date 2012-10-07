module Tekeya
  module Feed
    module Attachment
      extend ActiveSupport::Concern

      included do
        belongs_to :activity
      end

      module ClassMethods
      end

    end
  end
end