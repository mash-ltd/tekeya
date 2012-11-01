module Tekeya
  module Feed
    module Notification
      module Resque
        # A resque worker to cache the notification
        class CacheNotification
          include Tekeya::Feed::Notification::Resque

          @queue = :notification_queue

          # @private
          def self.perform(entity_id, entity_type, notification_key, score, attachments)
            # get the entity class
            entity_type = entity_type.safe_constantize
            entity = entity_type.where(entity_type.entity_primary_key.to_sym => entity_id).first
            # keep track of the keys we delete in the trim operation for garbage collection
            removed_keys = []

            # write the notification to the aggregate set and the owner's feed
            ::Tekeya.redis.multi do
              write_aggregate(notification_key, attachments)
              write_to_feed(entity.notifications_feed_key, score, notification_key)
            end

            # trim the profile feed
            removed_keys += trim_feed(entity.profile_feed_key)

            # cleanup the garbage
            collect_garbage removed_keys
          end

          private

          # Writes the notification and its' attachments to the aggregate set
          #
          # @param [String] notification_key the key of the notification to be added
          # @param [Array]  attachments an array of attachments associated with the notification
          def self.write_aggregate(notification_key, attachments)
            # save the aggregate set
            attachments.each do |attachment|
              ::Tekeya.redis.sadd(notification_key, attachment)
            end
          end
        end
      end
    end
  end
end