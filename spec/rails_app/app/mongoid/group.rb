class Group
  include Mongoid::Document
  include Tekeya::Entity::Group

  field :name, type: String
end