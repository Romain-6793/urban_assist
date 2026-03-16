Rails.application.routes.draw do
  # ===========================
  # Authentification
  # ===========================
  devise_for :users

  # ===========================
  # Page principale / Chat
  # ===========================
  root to: "pages#home"

  # ===========================
  # Chats
  # ===========================
  resources :chats, only: [:index, :show, :destroy] do
    # Favoris liés à un chat spécifique
    resources :favorites, only: [:create, :destroy]
  end

  # ===========================
  # Messages
  # ===========================
  # Création et suppression uniquement
  resources :messages, only: [:create, :destroy]

  # ===========================
  # Favoris
  # ===========================
  # Vue globale des favoris
  resources :favorites, only: [:index]

end
