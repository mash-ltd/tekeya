module Tekeya
  module Feed
    module Notification
      module Resque
        extend ActiveSupport::Concern

        included do
          MAXTIMESTAMP = 7.days.ago.to_i unless defined?(MAXTIMESTAMP)

          include ::Tekeya::Feed::Activity::Resque
        end
      end
    end
  end
end