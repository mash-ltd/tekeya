module Tekeya
  module Feed
    module Activity
      extend ActiveSupport::Concern

      included do
        belongs_to    :entity, polymorphic: true, autosave: true
        has_many      :attachments, as: :attache, class_name: 'Tekeya::Attachment'

        before_create :group_activities
        after_create  :write_activity_in_redis
        after_destroy :delete_activity_from_redis

        accepts_nested_attributes_for :attachments

        validates_presence_of :attachments

        attr_writer :group_with_recent
      end

      # Check if this activity is cached in redis
      #
      # @return [Boolean] true if an aggregate of the activity exists in redis, false otherwise
      def cached_in_redis?
        ::Tekeya.redis.scard(activity_key) > 0
      end

      # Approximates the timestamp to the nearest 15 minutes for grouping activities
      #
      # @param  [Datetime] from_time the time to approximate
      # @return [Integer] the timestamp approximated to the nearest 15 minutes
      def score(from_time = nil)
        if self.group_with_recent
          if from_time.present?
            stamp = from_time.to_i

            # floors the timestamp to the nearest 15 minute
            return (stamp.to_f / 15.minutes).floor * 15.minutes
          else
            return current_time_from_proper_timezone.to_i
          end
        else
          return Time.now.to_i
        end
      end

      # Returns an activity key for usage in caching
      #
      # @return [String] the activity key
      def activity_key
        "activity:#{self.id}:#{self.entity_type}:#{self.entity.send(self.entity.entity_primary_key)}:#{self.activity_type}:#{score}"
      end

      # @private
      #
      # returns if the activity should be grouped with similar recent activities
      def group_with_recent
        @group_with_recent.nil? ? true : @group_with_recent
      end

      private

      # @private
      # Writes to the activity's aggregate set (a set of attachments associated with the activity)
      def write_activity_in_redis
        akey = activity_key
        tscore = score
        attachments_json = self.attachments.map{ |att| att.to_json(root: false, only: [:attachable_id, :attachable_type]) }

        # write the activity to the aggregate set and the owner's feed
        ::Tekeya.redis.multi do
          write_aggregate
          ::Tekeya::Feed::Activity::Resque::ActivityFanout.write_to_feed(self.entity.profile_feed_key, tscore, akey)
          ::Tekeya::Feed::Activity::Resque::ActivityFanout.write_to_feed(self.entity.feed_key, tscore, akey)
        end

        ::Resque.enqueue(::Tekeya::Feed::Activity::Resque::ActivityFanout, self.entity_id, self.entity_type, akey, tscore)
      end

      # @private
      # Checks if the activity should be grouped and aborts the creation of a new record
      def group_activities
        if self.group_with_recent
          self.created_at = current_time_from_proper_timezone
          rel = self.class.where(created_at: self.created_at, activity_type: self.activity_type, entity_id: self.entity_id, entity_type: entity_type)
          if rel.count > 0
            activity = rel.first
            activity.attachments << self.attachments
            self.id = activity.id
            self.reload
            return false
          end
        end
      end

      # @private
      # Deletes the activity's aggregate set when its deleted from the DB
      def delete_activity_from_redis
        ::Resque.enqueue(::Tekeya::Feed::Activity::Resque::DeleteActivity, self.activity_key)
      end

      # @private
      # Override AR's default created_at calculation formula
      def current_time_from_proper_timezone #:nodoc:
        zone = self.class.respond_to?(:default_timezone) ? self.class.default_timezone : :utc
        ctime = zone == :utc ? Time.now.utc : Time.now
        stamp = ctime.to_i

        # floors the timestamp to the nearest 15 minute
        return Time.at((stamp.to_f / 15.minutes).floor * 15.minutes)
      end

      # Writes the activity and its' attachments to the aggregate set
      #
      # @param [String] activity_key the key of the activity to be added
      # @param [Array]  attachments an array of attachments associated with the activity
      def write_aggregate
        # save the aggregate set
        self.attachments.map{ |att| att.to_json(root: false, only: [:attachable_id, :attachable_type]) }.each do |attachment|
          ::Tekeya.redis.sadd(activity_key, attachment)
        end
      end
    end
  end
end