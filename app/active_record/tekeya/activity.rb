module Tekeya
  class Activity < ::ActiveRecord::Base
    include ::Tekeya::Feed::Activity

    # TODO: create migration for basic activity fields
  end
end