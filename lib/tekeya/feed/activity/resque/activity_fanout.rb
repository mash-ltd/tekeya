module Tekeya
  module Feed
    module Activity
      module Resque
        # A resque worker to perform the activity fanout operation
        class ActivityFanout
          include Tekeya::Feed::Activity::Resque

          @queue = :activity_queue

          # @private
          def self.perform(entity_id, entity_type, activity_key, score)
            # get the entity class
            entity_type = entity_type.safe_constantize
            entity = entity_type.where(entity_type.entity_primary_key.to_sym => entity_id).first
            # we only need the feed keys of the trackers
            entity_trackers_feeds = entity.trackers.map(&:feed_key)
            # keep track of the keys we delete in the trim operation for garbage collection
            removed_keys = []

            # trim the profile feed
            removed_keys += trim_feed(entity.profile_feed_key)

            # Fanout the activity to the owner's trackers
            entity_trackers_feeds.each do |feed_key|
              # write the activity to the tracker's feed
              ::Tekeya.redis.multi do
                write_to_feed(feed_key, score, activity_key)
              end

              # trim the tracker's feed
              removed_keys += trim_feed(feed_key)
            end

            # cleanup the garbage
            collect_garbage removed_keys
          end
        end
      end
    end
  end
end