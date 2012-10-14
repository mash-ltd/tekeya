class Status < ActiveRecord::Base
  has_many :attachments, as: :attachable, class_name: "Tekeya::Attachment"
end
