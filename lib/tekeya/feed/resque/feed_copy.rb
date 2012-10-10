module Tekeya
  module Feed
    module Resque
      # A resque worker to copy activities when an entity tracks another
      class FeedCopy
        include Tekeya::Feed::Resque

        @queue = :activity_queue

        # @private
        def self.perform(tracked_feed_key, tracker_feed_key)
          # get the keys to the activities so we can increment the counters later
          activity_keys = ::Tekeya.redis.zrange(tracked_feed_key, 0, -1)

          ::Tekeya.redis.multi do
            # copy the latest activities from the tracked entity to the tracker feed
            ::Tekeya.redis.zunionstore(tracker_feed_key, [tracker_feed_key, tracked_feed_key])

            # increment the activity counter
            activity_keys.each do |activity_key|
              activity_counter_key = "#{activity_key}:counter"
              ::Tekeya.redis.incr(activity_counter_key)
            end
          end

          # trim the tracker feed and cleanup
          collect_garbage trim_feed(tracker_feed_key)
        end
      end
    end
  end
end