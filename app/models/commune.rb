class Commune < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :chats, through: :favorites
end
