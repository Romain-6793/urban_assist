class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:create]

  # ===========================
  # Affiche la liste des favoris de l'utilisateur
  # ===========================
  def index
    # Récupère uniquement les favoris associés aux chats de l'utilisateur
    @favorites = Favorite.joins(:chat).where(chats: { user_id: current_user.id })
  end

  # ===========================
  # Crée un nouveau favori pour un chat
  # ===========================
  def create
    @favorite = @chat.favorites.build(favorite_params)

    if @favorite.save
      redirect_to root_path(chat_id: @chat.id), notice: "Commune ajoutée aux favoris"
    else
      redirect_to root_path(chat_id: @chat.id), alert: "Impossible d’ajouter aux favoris"
    end
  end

  private

  # ===========================
  # Récupère le chat correspondant à l'utilisateur
  # ===========================
  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  # ===========================
  # Paramètres autorisés pour un favori
  # ===========================
  def favorite_params
    params.require(:favorite).permit(:commune_id, :note)
  end
end
