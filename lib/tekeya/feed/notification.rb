module Tekeya
  module Feed
    module Notification
      extend ActiveSupport::Concern

      included do
        belongs_to    :entity, polymorphic: true, autosave: true
        belongs_to    :subject, polymorphic: true, autosave: true
        has_many      :actors, as: :attache, class_name: 'Tekeya::Attachment'

        before_create :group_notifications

        accepts_nested_attributes_for :actors, :subject

        validates_presence_of :actors

        attr_writer :group_with_recent
        attr_accessible :entity, :subject, :actors, :notification_type, :read, :group_with_recent
      end

      module ClassMethods
        def notify!(to_notify, notification_type, subject, *args)
          options = args.extract_options!
          options[:group] = options[:group].nil? ? true : options[:group]

          actors = []
          args.each do |attachable|
            actors << ::Tekeya::Attachment.new(attachable: attachable)
          end

          to_notify.each do |entity|
            entity.notifications.create notification_type: notification_type, subject: subject, actors: actors, group_with_recent: options[:group]
          end
        end
      end

      # Approximates the timestamp to the nearest 15 minutes for grouping activities
      #
      # @param  [Datetime] from_time the time to approximate
      # @return [Integer] the timestamp approximated to the nearest 15 minutes
      def score(from_time = nil)
        if from_time.present?
          stamp = from_time.to_i

          # floors the timestamp to the nearest 15 minute
          return (stamp.to_f / 15.minutes).floor * 15.minutes
        else
          return current_time_from_proper_timezone.to_i
        end
      end

      # Marks the notification as read
      def read!
        self.update_attribute :read, true
      end

      # @private
      #
      # returns if the notification should be grouped with similar recent activities
      def group_with_recent
        @group_with_recent.nil? ? true : @group_with_recent
      end

      private

      # @private
      # Checks if the notification should be grouped and aborts the creation of a new record
      def group_notifications
        if self.group_with_recent
          self.created_at = current_time_from_proper_timezone
          rel = self.class.where(created_at: self.created_at, notification_type: self.notification_type, entity_id: self.entity_id, entity_type: self.entity_type, subject_id: self.subject_id)
          if rel.count > 0
            notification = rel.first
            notification.actors << self.actors
            self.id = notification.id
            self.reload
            return false
          end
        end
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
    end
  end
end
