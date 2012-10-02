module Tekeya
  module Entity
    extend ActiveSupport::Concern

    included do
      class_attribute :entity_primary_key

      private_class_method :"entity_primary_key="

      self.entity_primary_key = :id
    end

    module ClassMethods
      def is_entity?
        return true
      end
    end

    def track(entity)
      add_relation(self, entity, :tracks)
    end

    def tracking(type = nil)
      relations_of(type, :tracks, self)
    end

    def trackers(type = nil)
      relations_of(self, :tracks, type)
    end

    def tracks?(entity)
      relation_exists?(self, entity, :tracks)
    end

    def untrack(entity)
      delete_relation(self, entity, :tracks)
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

    def post(content)
      FeedItem.create(content: content, entity_type: entity.class_name, entity_id: self.send(self.class.entity_primary_key))
      # Create activity in DB
      # Create attachements
      # Create activity in Redis
      # Call Resque FanOut task
    end

    private
    def activity_key(activity_type)
      "#{self.class_name}:#{self.send(self.entity_primary_key)}:#{activity_type}:#{current_time_from_proper_timezone}"
    end

    def add_relation(from, to, type)
      ::Tekeya.relations.add(from.send(from.class.entity_primary_key), from.class_name, to.send(to.class.entity_primary_key), to.class_name, type)
    end

    def delete_relation(from, to, type)
      ::Tekeya.relations.delete(from.send(from.class.entity_primary_key), from.class_name, to.send(to.class.entity_primary_key), to.class_name, :tracks)
    end

    def relations_of(from, entity_type, relation_type)
      ::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class_name, nil, entity_type, relation_type).entries
    end

    def relation_exists?(from, to, type)
      !::Tekeya.relations.where(from.send(from.class.entity_primary_key), from.class_name, to.send(to.class.entity_primary_key), entity.class_name, :tracks).entries.empty?
    end
  end
end
