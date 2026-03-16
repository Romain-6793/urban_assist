class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :load_sidebar_data, if: :user_signed_in?

  private

  def load_sidebar_data
    @chats = current_user.chats
    @favorites = Favorite.joins(:chat)
                         .where(chats: { user_id: current_user.id })
                         .includes(:commune)
  end
end
