module Tekeya
  class Attachment
    include Mongoid::Document
    include ::Tekeya::Feed::Attachment

    field :activity_type, type: String
    field :content      , type: String 
    field :entity_id    , type: Integer
    field :entity_type  , type: String
  end
end