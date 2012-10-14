class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tekeya::Entity

  field :name, type: String
end