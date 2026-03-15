class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:create]

  # ===========================
  # GET /favorites
  # Liste tous les favoris de l'utilisateur connecté
  # Charge les communes associées en une seule requête (évite N+1)
  # ===========================
  def index
    @favorites = Favorite.joins(:chat)
                         .where(chats: { user_id: current_user.id })
                         .includes(:commune)
  end

  # ===========================
  # POST /chats/:chat_id/favorites
  # Crée un favori associé au chat courant
  # ===========================
  def create
    @favorite = @chat.favorites.build(favorite_params)

    if @favorite.save
      redirect_to root_path(chat_id: @chat.id), notice: "Commune ajoutée aux favoris"
    else
      redirect_to root_path(chat_id: @chat.id), alert: "Impossible d'ajouter aux favoris"
    end
  end

  # ===========================
  # DELETE /chats/:chat_id/favorites/:id
  # Supprime un favori — vérifie que le chat appartient bien à l'utilisateur
  # ===========================
  def destroy
    @chat = current_user.chats.find(params[:chat_id])
    @favorite = @chat.favorites.find(params[:id])
    @favorite.destroy
    redirect_to favorites_path, notice: "Favori supprimé"
  end

  private

  # ===========================
  # Récupère le chat via l'utilisateur connecté
  # Empêche un utilisateur d'accéder aux chats d'un autre
  # ===========================
  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  # ===========================
  # Paramètres autorisés pour la création d'un favori
  # ===========================
  def favorite_params
    params.require(:favorite).permit(:commune_id, :note)
  end
end
