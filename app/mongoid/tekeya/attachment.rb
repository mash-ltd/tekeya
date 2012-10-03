module Tekeya
  class Attachment
    include Mongoid::Document
    include ::Tekeya::Feed::Attachment

    # TODO: define basic attachment fields
  end
end