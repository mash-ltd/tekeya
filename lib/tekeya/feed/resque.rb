module Tekeya
  module Feed
    module Resque
      extend ActiveSupport::Concern

      included do
        MAXTIMESTAMP = 10.days.ago.to_i
      end

      module ClassMethods
        private
        # Writes the activity reference to the feed with the supplied key
        #
        # @param [String]  feed_key the key of the feed where the activity will be referenced
        # @param [Integer] score the score of the activity (timestamp) used to order the feed
        # @param [String]  activity_key a string containing the key to reference the activity
        def write_to_feed(feed_key, score, activity_key)
          # add the activity to the owner's profile feed
          ::Tekeya.redis.zadd(feed_key, score, activity_key)
          # increment the activity counter to keep track of its presence in feeds
          activity_counter_key = "#{activity_key}:counter"
          ::Tekeya.redis.incr(activity_counter_key)
        end

        # Trims the feed according to the MAXTIMESTAMP set and returns the removed keys (for garbage collection)
        #
        # @param [String] feed_key a string containing the key of the feed to be trimed
        def trim_feed(feed_key)
          removed_keys = ::Tekeya.redis.zrevrangebyscore(feed_key, '-inf', MAXTIMESTAMP)
          ::Tekeya.redis.zremrangebyscore(feed_key, '-inf', MAXTIMESTAMP)

          return removed_keys
        end

        # Checks if the given keys are referenced in any feed otherwise removes the activity
        #
        # @param [Array] keys an array of activity keys to be removed
        def collect_garbage(keys)
          keys.each do |key|
            activity_counter_key = "#{key}:counter"
            # Check if the key is referenced anywhere
            if ::Tekeya.redis.get(activity_counter_key) <= 0
              # Delete the activity and the counter
              ::Tekeya.redis.multi do
                ::Tekeya.redis.remove(key)
                ::Tekeya.redis.remove(activity_counter_key)
              end
            end
          end
        end
      end

    end
  end
end