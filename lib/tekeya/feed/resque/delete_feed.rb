module Tekeya
  module Feed
    module Resque
      # A resque worker to copy activities when an entity tracks another
      class DeleteFeed
        include Tekeya::Feed::Resque

        @queue = :activity_queue

        # @private
        def self.perform(untracked_feed_key, untracker_feed_key)
          # get the keys to the activities so we can decrement the counters later
          activity_keys = ::Tekeya.redis.zrange(untracked_feed_key, 0, -1)

          ::Tekeya.redis.multi do
            # delete the latest activities of the untracked entity from the tracker feed
            ::Tekeya.redis.zrem(untracker_feed_key, activity_keys)

            # increment the activity counter
            activity_keys.each do |activity_key|
              activity_counter_key = "#{activity_key}:counter"
              ::Tekeya.redis.decr(activity_counter_key)
            end
          end

          # trim the tracker feed and cleanup
          collect_garbage trim_feed(untracker_feed_key)
        end
      end
    end
  end
end