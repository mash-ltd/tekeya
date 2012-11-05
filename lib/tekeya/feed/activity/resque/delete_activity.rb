module Tekeya
  module Feed
    module Activity
      module Resque
        # A resque worker to copy activities when an entity tracks another
        class DeleteActivity
          include Tekeya::Feed::Activity::Resque

          @queue = :activity_queue

          # @private
          def self.perform(activity_aggregate_key)
            # get the activity properties from the key
            key_components  = activity_aggregate_key.split(':')
            entity_type     = key_components[2].safe_constantize
            entity_id       = key_components[3]

            # get the entity
            entity = entity_type.where(entity_type.entity_primary_key.to_sym => entity_id).first
            # we only need the feed keys of the trackers
            entity_trackers_feeds = entity.trackers.map(&:feed_key)
            entity_trackers_feeds << entity.profile_feed_key
            entity_trackers_feeds << entity.feed_key

            # remove the aggregate key from the trackers' feeds and prepare the activity for garbage collection
            ::Tekeya.redis.multi do
              entity_trackers_feeds.each do |feed_key|
                if ::Tekeya.redis.zrank(feed_key, activity_aggregate_key)
                  # remove the activity aggregate key from the feed
                  ::Tekeya.redis.zrem(feed_key, activity_aggregate_key)
                  # decrement the activity counter
                  ::Tekeya.redis.decr("#{activity_aggregate_key}:counter")
                end
              end
            end

            # trim the tracker feed and cleanup
            collect_garbage [activity_aggregate_key]
          end
        end
      end
    end
  end
end