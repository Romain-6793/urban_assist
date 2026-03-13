class Commune < ApplicationRecord
  has_many :favorites
  has_many :chats, through: :favorites
end
