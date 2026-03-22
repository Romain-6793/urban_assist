class Chat < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy
  has_many :favorites
  has_many :communes, through: :favorites

  validates :title, presence: true, length: { maximum: 100 }
end
