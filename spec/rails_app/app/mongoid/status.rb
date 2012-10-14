class Status
  include Mongoid::Document
  include Tekeya::Feed::Attachable

  field :content, type: String
end