class Status
  include Mongoid::Document

  field :content, type: String

  has_many :attachments, as: :attachable, class_name: "Tekeya::Attachment"
end