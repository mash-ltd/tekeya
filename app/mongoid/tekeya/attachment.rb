module Tekeya
  class Attachment
    include Mongoid::Document
    include ::Tekeya::Feed::Attachment
  end
end