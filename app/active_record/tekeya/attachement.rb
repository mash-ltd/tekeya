module Tekeya
  class Attachement < ::ActiveRecord::Base
    include ::Tekeya::Feed::Attachement

    # TODO: create migration for basic attachement fields
  end
end