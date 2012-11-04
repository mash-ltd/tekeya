module Tekeya
  class Notification
    include Mongoid::Document
    include Mongoid::Timestamps
    include ::Tekeya::Feed::Notification

    field :notification_type, type: String
    field :read, type: Boolean, default: false
  end
end