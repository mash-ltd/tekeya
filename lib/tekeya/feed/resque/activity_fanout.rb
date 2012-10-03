module Tekeya
  module Feed
    class Resque::ActivityFanout
      @queue = :activity_queue

      def self.perform(entity_id, entity_type, activity_key, score, activity_content, attachments)
        entity_type = entity_type.constantize
        entity = entity_type.where(entity_type.entity_primary_key.to_sym => entity_id).first

        ::Tekeya.redis.multi do
          # Save the aggregate set
          ::Tekeya.redis.sadd(activity_key, activity_content)
          attachments.each do |attachment|
            ::Tekeya.redis.sadd(activity_key, attachment.to_json)
          end

          # Add the activity to the owner's profile feed
          ::Tekeya.redis.zadd(entity.feed_key, score, activity_key)

          entity.trackers.each do |tracker|
            # Add the activity to the trackers' feeds
            ::Tekeya.redis.zadd(tracker.feed_key, score, activity_key)       
          end
        end
      end
    end
  end
end