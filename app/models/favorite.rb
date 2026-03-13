class Favorite < ApplicationRecord
  belongs_to :chat
  belongs_to :commune
end
