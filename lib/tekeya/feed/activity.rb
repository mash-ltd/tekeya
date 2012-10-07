module Tekeya
  module Feed
    module Activity
      extend ActiveSupport::Concern

      included do
        belongs_to    :entity, polymorphic: true
        has_many      :attachments, class_name: 'Tekeya::Attachment'

        after_create  :write_activity_in_redis
      end

      module ClassMethods
      end

      private

      # Writes to the activity aggregate set (a set of attachments associated with the activity)
      def write_activity_in_redis
        akey = activity_key
        score = calculate_timestamp
        ::Resque.enqueue(::Tekeya::Feed::Resque::ActivityFanout, self.entity_id, self.entity_type, akey, score, self.content, self.attachments)
      end

      # returns an activity key for the entity
      def activity_key
        "#{self.entity_type}:#{self.entity.send(self.entity.entity_primary_key)}:#{self.activity_type}:#{calculate_timestamp}"
      end

      # Approximates the timestamp to the nearest 15 minutes
      def calculate_timestamp
        stamp = current_time_from_proper_timezone.to_i

        # floors the timestamp to the nearest 15 minute
        return (stamp.to_f / 15.minutes).floor * 15.minutes
      end
    end
  end
end