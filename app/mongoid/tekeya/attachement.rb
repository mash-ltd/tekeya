module Tekeya
  class Attachement
    include Mongoid::Document
    include ::Tekeya::Feed::Attachement

    # TODO: define basic attachement fields
  end
end