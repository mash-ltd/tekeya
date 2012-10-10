module Tekeya
  module Errors
    class TekeyaFatal < ::StandardError
      def initialize(message)
        super(message)
        ::ActiveSupport::Notifications.
          instrument('tekeya_fatal.tekeya', :message => message)
      end
    end
  end
end