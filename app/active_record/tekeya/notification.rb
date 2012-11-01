module Tekeya
  class Notification < ::ActiveRecord::Base
    include ::Tekeya::Feed::Notification
  end
end