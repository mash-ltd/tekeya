module Tekeya
  module Entity
    extend ActiveSupport::Concern
    included do
      class_attribute :entity_primary_key

      private_class_method :"entity_primary_key="

      self.entity_primary_key = :id
    end

    module ClassMethods
    end

    def track(entity)
      ::Tekeya.relations.add(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :tracks)
    end

    def trackers(type = nil)
      ::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, nil, type, :tracks).entries
    end

    def tracks?(entity)
      !::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :tracks).entries.empty?
    end

    def untrack(entity)
      ::Tekeya.relations.delete(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :tracks)
    end

    def block(entity)
      ::Tekeya.relations.add(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :blocks)
    end

    def blocked(type = nil)
      ::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, nil, type, :blocks).entries
    end

    def blocks?(entity)
      !::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :blocks).entries.empty?
    end

    def unblock(entity)
      ::Tekeya.relations.delete(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :blocks)
    end

    def join(group)
      ::Tekeya.relations.add(self.send(self.class.entity_primary_key), self.class_name, group.send(group.class.entity_primary_key), group.class_name, :joins)
    end

    def groups(type = nil)
      ::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, nil, type, :joins).entries
    end

    def member_of?(group)
      !::Tekeya.relations.where(self.send(self.class.entity_primary_key), self.class_name, group.send(group.class.entity_primary_key), group.class_name, :joins).entries.empty?
    end

    def leave(group)
      ::Tekeya.relations.delete(self.send(self.class.entity_primary_key), self.class_name, entity.send(entity.class.entity_primary_key), entity.class_name, :joins)
    end
  end
end
