module Tekeya
  module Feed
    module Activity
      class Item
        attr_reader :activity_id, :activity_type, :attachments, :actor, :timestamp

        def initialize(activity_id, activity_type, attachments, actor, timestamp)
          @activity_id = activity_id
          @activity_type = activity_type
          @attachments = attachments
          @actor = actor
          @timestamp = timestamp
        end

        # Builds a feed item from a redis activity
        # 
        # @param  [String] key the aggregate key of the activity
        # @param  [Tekeya::Entity] act_actor the activty actor; when nil the actor is retrieved from the aggregate key
        # @return [Tekeya::Feed::Activity::Item] the feed item
        def self.from_redis(key, act_actor = nil)
          key_components  = key.split(':')
          
          act_id          = key_components[1]
          act_type        = key_components[4].to_sym
          act_time        = Time.at(key_components[5].to_i)
          
          if act_actor.nil?
            actor_class = key_components[2].safe_constantize
            act_actor = actor_class.where(:"#{actor_class.entity_primary_key}" => key_components[3]).first
          end

          act_attachments = ::Tekeya.redis.smembers(key).map{|act| 
            ActiveSupport::JSON.decode(act)
          }.map{|att| 
            att['attachable_type'].safe_constantize.find att['attachable_id']
          }

          return self.new(act_id, act_type, act_attachments, act_actor, act_time)
        end

        # Builds a feed item a DB activity
        # 
        # @param  [Tekeya::Activity] activity the source activity
        # @param  [Tekeya::Entity] act_actor the activty actor; when nil the actor is retrieved from the activity
        # @return [Tekeya::Feed::Activity::Item] the feed item
        def self.from_db(activity, act_actor = nil)
          act_id            = activity.id.to_s
          act_type          = activity.activity_type.to_sym
          act_time          = activity.created_at
          act_actor       ||= activity.entity
          act_attachments   = activity.attachments.map(&:attachable)

          return self.new(act_id, act_type, act_attachments, act_actor, act_time)
        end
      end
    end
  end
end