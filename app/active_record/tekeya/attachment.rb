module Tekeya
  class Attachment < ::ActiveRecord::Base
    include ::Tekeya::Feed::Attachment
  end
end