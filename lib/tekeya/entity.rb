module Tekeya
  # Represents a tekeya entity, the main building block of the engine
  module Entity
    extend ActiveSupport::Concern

    FEEDITEMSPERPAGE = 10

    included do
      class_attribute :entity_primary_key

      private_class_method :"entity_primary_key="

      self.entity_primary_key = :id

      has_many :activities, as: :entity, class_name: "::Tekeya::Activity", dependent: :destroy do
        def recent
          unless self.included_modules.map(&:to_s).include?("Mongoid::Document")
            where("created_at > ?", 10.days.ago).order('created_at DESC').limit(FEEDITEMSPERPAGE)
          else
            where(:created_at.gte => 10.days.ago).desc('created_at').limit(FEEDITEMSPERPAGE)
          end
        end
      end
    end

    # Tracks the given entity and copies it's recent feed to the tracker feed
    #
    # @param [Entity] entity the entity to track
    # @return [Boolean]
    def track(entity)
      check_if_entity(entity)
      raise ::Tekeya::Errors::TekeyaRelationAlreadyExists.new("Already tracking #{entity}") if self.tracks?(entity)

      ret = add_relation(self, entity, :tracks)
      ::Resque.enqueue(::Tekeya::Feed::Resque::FeedCopy, entity.profile_feed_key, self.feed_key)
      return ret
    end

    # Return a list of entities being tracked by this entity
    #
    # @param  [String] type used to return a certain type of entities being tracked
    # @return [Array] the entities tracked by this entity
    def tracking(type = nil)
      relations_of(self, :tracks, type)
    end

    # Returns a list of entities tracking this entity
    #
    # @param  [String] type used to return a certain type of entities being tracked
    # @return [Array] the entities tracking this entity
    def trackers(type = nil)
      relations_of(self, :tracks, type, true)
    end

    # Checks if this entity is tracking the given entity
    #
    # @param  [Entity] entity the entity to check
    # @return [Boolean] true if this entity is tracking the given entity, false otherwise
    def tracks?(entity)
      check_if_entity(entity)
      relation_exists?(self, entity, :tracks)
    end

    # Untracks the given entity and deletes recent activities of the untracked entity from this entity's feed
    #
    # @param [Entity] entity the entity to untrack
    # @return [Boolean]
    def untrack(entity)
      check_if_entity(entity)
      raise ::Tekeya::Errors::TekeyaRelationNonExistent.new("Can't untrack an untracked entity") unless self.tracks?(entity)

      ret = delete_relation(self, entity, :tracks)
      ::Resque.enqueue(::Tekeya::Feed::Resque::UntrackFeed, entity.profile_feed_key, self.feed_key)
      return ret
    end

    # Blocks the given entity and removes any tracking relation between both entities
    #
    # @param [Entity] entity the entity to block
    # @return [Boolean]
    def block(entity)
      check_if_entity(entity)
      raise ::Tekeya::Errors::TekeyaRelationAlreadyExists.new("Already blocking #{entity}") if self.blocks?(entity)

      unless entity.is_tekeya_group?
        self.untrack(entity) if self.tracks?(entity)
        entity.untrack(self) if entity.tracks?(self)
      end

      add_relation(self, entity, :blocks)
    end

    # Returns a list of entities blocked by this entity
    #
    # @param  [String] type used to return a certain type of entities blocked
    # @return [Array] the entities blocked by this entity
    def blocked(type = nil)
      relations_of(self, :blocks, type)
    end

    # Checks if this entity is blocking the given entity
    #
    # @param  [Entity] entity the entity to check
    # @return [Boolean] true if this entity is blocking the given entity, false otherwise
    def blocks?(entity)
      check_if_entity(entity)
      relation_exists?(self, entity, :blocks)
    end

    # Unblock the given entity
    #
    # @param [Entity] entity the entity to unblock
    # @return [Boolean]
    def unblock(entity)
      check_if_entity(entity)
      raise ::Tekeya::Errors::TekeyaRelationNonExistent.new("Can't unblock an unblocked entity") unless self.blocks?(entity)

      delete_relation(self, entity, :blocks)
    end

    # Joins the given group and tracks it
    #
    # @note will automatically track the group
    # @param [Group] group the group to track
    # @param [Boolean] track_also if set to false automatic tracking is disabled
    # @return [Boolean]
    def join(group, track_also = true)
      check_if_group(group)
      raise ::Tekeya::Errors::TekeyaRelationAlreadyExists.new("Already a member of #{group}") if self.member_of?(group)

      ret = add_relation(self, group, :joins)

      ret &= self.track(group) if track_also && !self.tracks?(group)

      return ret
    end

    # Return a list of groups joined by this entity
    #
    # @param  [String] type used to return a certain type of groups joined
    # @return [Array] the groups joined by this entity
    def groups(type = nil)
      relations_of(self, :joins, type)
    end

    # Checks if this entity is a member of the given group
    #
    # @param  [Group] group the group to check
    # @return [Boolean] true if this entity is a member of the given group, false otherwise
    def member_of?(group)
      check_if_group(group)
      relation_exists?(self, group, :joins)
    end

    # Leaves the given group and untracks it
    #
    # @param [Group] group the group to untrack
    # @return [Boolean]
    def leave(group)
      check_if_group(group)
      raise ::Tekeya::Errors::TekeyaRelationNonExistent.new("Can't leave an unjoined group") unless self.member_of?(group)

      ret = delete_relation(self, group, :joins)

      ret &= self.untrack(group) if self.tracks?(group)

      return ret
    end

    # Returns the entity's recent activities
    #
    # @return [Array] the list of recent activities by this entity
    def profile_feed
      acts = []
      pkey = self.profile_feed_key
      recent_activities_count = ::Tekeya.redis.zcard(pkey)
      
      # Check if the cache is not empty
      if recent_activities_count > 0
        # Retrieve the aggregate keys from redis
        acts_keys = ::Tekeya.redis.zrange(pkey, 0, -1)
        # Retrieve the aggregates
        acts_keys.each do |act_key|
          acts << ::Tekeya::Feed::FeedItem.from_redis(act_key, self)
        end
      else
        # Retrieve the activities from the DB
        db_recent_activities = self.activities.recent
        db_recent_activities.each do |activity|
          acts << ::Tekeya::Feed::FeedItem.from_db(activity, self)
        end
      end

      return acts
    end
    
    # Returns the entity's feed
    #
    # @return [Array] the list of activities for the entities tracked by this entity
    def feed
      acts = []
      fkey = self.feed_key
      recent_activities_count = ::Tekeya.redis.zcard(fkey)
      
      # Check if the cache is not empty
      if recent_activities_count > 0
        # Retrieve the aggregate keys from redis
        acts_keys = ::Tekeya.redis.zrange(fkey, 0, -1)
        # Retrieve the aggregates
        acts_keys.each do |act_key|
          acts << ::Tekeya::Feed::FeedItem.from_redis(act_key, self)
        end
      else
        # Retrieve the activities from the DB
        self.tracking.each do |tracker|
          db_recent_activities = tracker.activities.recent
          db_recent_activities.each do |activity|
            acts << ::Tekeya::Feed::FeedItem.from_db(activity, tracker)
          end
        end
      end

      return acts
    end

    # @private
    # Returns a unique key for the entity's profile feed in redis
    def profile_feed_key
      "#{self.class.name}:#{self.send(self.entity_primary_key)}:profile:feed"
    end

    # @private
    # Returns a unique key for the entity's feed in redis
    def feed_key
      "#{self.class.name}:#{self.send(self.entity_primary_key)}:feed"
    end

    # A method to identify the entity
    #
    # @return [Boolean] true
    def is_tekeya_entity?
      return true
    end

    # A method to identify the entity as a non group
    #
    # @return [Boolean] false
    def is_tekeya_group?
      return false
    end

    private

    # @private
    # Checks if the given argument is an entity and raises an error if its not
    def check_if_entity(entity)
      raise ::Tekeya::Errors::TekeyaNonEntity.new("Supplied argument is not a Tekeya::Entity") unless entity.present? && entity.is_tekeya_entity?
    end

    # @private
    # Checks if the given argument is a group and raises an error if its not
    def check_if_group(group)
      raise ::Tekeya::Errors::TekeyaNonGroup.new("Supplied argument is not a Tekeya::Entity::Group") unless group.present? && group.is_tekeya_group?
    end

    # @private
    # Adds a rebat relation
    def add_relation(from, to, type)
      ::Tekeya.relations.add(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), to.class.name, 0, type)
    end

    # @private
    # Deletes a rebat relation
    def delete_relation(from, to, type)
      ::Tekeya.relations.delete(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), to.class.name, type)
    end

    # @private
    # Retrieves rebat relations
    def relations_of(from, relation_type, entity_type, reverse = false)
      result_entity_class = entity_type.safe_constantize if entity_type
      unless reverse
        ::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class.name, nil, entity_type, relation_type).entries.map do |entry|
          result_entity_class ||= entry.toEntityType.safe_constantize
          result_entity_class.where(:"#{result_entity_class.entity_primary_key}" => entry.toEntityId).first
        end
      else
        ::Tekeya.relations.where(nil, entity_type, from.send(from.class.entity_primary_key), from.class.name, relation_type).entries.map do |entry|
          result_entity_class ||= entry.fromEntityType.safe_constantize
          result_entity_class.where(:"#{result_entity_class.entity_primary_key}" => entry.fromEntityId).first
        end
      end
    end

    # @private
    # Checks if a rebat relation exists
    def relation_exists?(from, to, type)
      !::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), to.class.name, type).entries.empty?
    end
  end
end
