class Message < ApplicationRecord
  acts_as_message

  belongs_to :chat

  validates :content, presence: true
end
