module Tekeya
  class Activity
    include Mongoid::Document
    include Mongoid::Timestamps
    include ::Tekeya::Feed::Activity

    field :activity_type, type: String
  end
end