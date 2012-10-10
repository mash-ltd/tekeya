module Tekeya
  module Errors
    class TekeyaError < ::StandardError
      def initialize(message)
        super(message)
        ::ActiveSupport::Notifications.
          instrument('tekeya_error.tekeya', :message => message)
      end
    end
  end
end