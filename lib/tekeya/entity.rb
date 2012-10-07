module Tekeya
  module Entity
    extend ActiveSupport::Concern

    included do
      class_attribute :entity_primary_key

      private_class_method :"entity_primary_key="

      self.entity_primary_key = :id

      has_many :activities, as: :entity, class_name: ::Tekeya::Activity, dependent: :destroy
    end

    module ClassMethods
      # A method to identify the entity's heritage
      def is_entity?
        return true
      end
    end

    # Tracks the given entity and copies it's recent feed to the tracker feed
    #
    # @param [Entity] entity the entity to track
    def track(entity)
      add_relation(self, entity, :tracks)
      ::Resque.enqueue(::Tekeya::Feed::Resque::FeedCopy, entity.profile_feed_key, self.feed_key)
    end

    # Return a list of entities being tracked by this entity
    #
    # @param  [String, nil] type used to return a certain type of entities being tracked
    # @return [Array] the entities tracked by this entity
    def tracking(type = nil)
      relations_of(type, :tracks, self)
    end

    # Returns a list of entities tracking this entity
    #
    # @param  [String, nil] type used to return a certain type of entities being tracked
    # @return [Array] the entities tracking this entity
    def trackers(type = nil)
      relations_of(self, :tracks, type)
    end

    # Checks if this entity is tracking the given entity
    #
    # @param  [Entity] entity the entity to check
    # @return [Boolean] true if this entity is tracking the given entity, false otherwise
    def tracks?(entity)
      relation_exists?(self, entity, :tracks)
    end

    # Untracks the given entity and deletes recent activities of the untracked entity from this entity's feed
    #
    # @param [Entity] entity the entity to untrack
    def untrack(entity)
      delete_relation(self, entity, :tracks)
      ::Resque.enqueue(::Tekeya::Feed::Resque::DeleteFeed, entity.profile_feed_key, self.feed_key)
    end

    def block(entity)
      add_relation(self, entity, :blocks)
    end

    def blocked(type = nil)
      relations_of(self, :blocks, type)
    end

    def blocks?(entity)
      relation_exists?(self, entity, :blocks)
    end

    def unblock(entity)
      delete_relation(self, entity, :blocks)
    end

    def join(group)
      add_relation(self, entity, :joins)
    end

    def groups(type = nil)
      relations_of(self, :joins, type)
    end

    def member_of?(group)
      relation_exists?(self, entity, :joins)
    end

    def leave(group)
      delete_relation(self, entity, :joins)
    end

    def profile_feed
    end
    
    def feed
    end

    def profile_feed_key
      "#{self.class.name}:#{self.send(self.entity_primary_key)}:profile:feed"
    end

    def feed_key
      "#{self.class.name}:#{self.send(self.entity_primary_key)}:feed"
    end

    private

    def add_relation(from, to, type)
      ::Tekeya.relations.add(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), to.class.name, type)
    end

    def delete_relation(from, to, type)
      ::Tekeya.relations.delete(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), to.class.name, :tracks)
    end

    def relations_of(from, relation_type, entity_type)
      result_entity_class = entity_type.constantize if entity_type
      ::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class.name, nil, entity_type, relation_type).entries.map do |entry|
        result_entity_class ||= entry.toEntityType.constantize
        result_entity_class.where(result_entity_class.entity_primary_key.to_sym => entry.toEntityId).first
      end
    end

    def relation_exists?(from, to, type)
      !::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class.name, to.send(to.class.entity_primary_key), entity.class.name, :tracks).entries.empty?
    end
  end
end
