class PagesController < ApplicationController
  before_action :authenticate_user!

  # ===========================
  # Page d'accueil / Chat principal
  # ===========================
  def home
    # Récupère tous les chats de l'utilisateur, triés par mise à jour récente
    @chats = current_user.chats.order(updated_at: :desc)

    if params[:chat_id].present?
      # Récupère le chat sélectionné et ses messages
      @chat = current_user.chats.find(params[:chat_id])
      @messages = @chat.messages.order(:created_at)
      @suggested_communes = Commune.where(id: session[:suggested_commune_ids] || [])
      @favorite_commune_ids = @chat.favorites.pluck(:commune_id)
    else
      # Aucun chat sélectionné
      @chat = nil
      @messages = []
      @suggested_communes = []
      @favorite_commune_ids = []
    end
  end
end
