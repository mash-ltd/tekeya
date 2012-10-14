module Tekeya
  module Feed
    module Attachment
      extend ActiveSupport::Concern

      included do
        belongs_to :activity
        belongs_to :attachable, polymorphic: true, autosave: true

        include ActiveModel::Serializers::JSON
      end

      module ClassMethods
      end

    end
  end
end