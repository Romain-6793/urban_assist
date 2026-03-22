class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show, :destroy, :update]

  def index
    @chats = current_user.chats.order(updated_at: :desc)
  end

  def update
    if @chat.update(chat_params)
      redirect_back fallback_location: root_path, notice: "Titre modifié"
    else
      redirect_back fallback_location: root_path, alert: "Titre invalide"
    end
  end
  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages.order(created_at: :asc)
    @suggested_communes = Commune.where(id: session[:suggested_commune_ids] || [])
    @favorite_commune_ids = @chat.favorites.pluck(:commune_id)
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to root_path, notice: "Conversation supprimée"
  end

  private

  def chat_params
    params.require(:chat).permit(:title)
  end

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end
end
