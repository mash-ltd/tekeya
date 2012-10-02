# string  activity_type
# string  content
# integer entity_id
# string  entity_type
module Tekeya
  module Feed
    module Activity
      extend ActiveSupport::Concern

      included do
        belongs_to  :entity, polymorphic: true
        has_many    :attachments, as: :activity
      end

      module ClassMethods
      end

    end
  end
end