module Tekeya
  class Attachment < ::ActiveRecord::Base
    include ::Tekeya::Feed::Attachment

    # TODO: create migration for basic attachment fields
  end
end