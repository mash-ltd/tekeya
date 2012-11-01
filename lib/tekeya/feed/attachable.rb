module Tekeya
  module Feed
    module Attachable
      extend ActiveSupport::Concern

      included do
        has_many :attachments, as: :attachable, class_name: "Tekeya::Attachment"
      end

      def is_tekeya_attachable
        true
      end
    end
  end
end