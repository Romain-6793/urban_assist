class MessagesController < ApplicationController
  before_action :authenticate_user!

  # ===========================
  # Crée un nouveau message
  # ===========================
  def create
    # Récupère le contenu et supprime les espaces
    content = params[:message][:content].to_s.strip

    # Si le message est vide, on retourne au chat actuel sans rien créer
    return redirect_to root_path(chat_id: params[:chat_id]) if content.blank?

    # Récupère le chat existant ou crée un nouveau chat associé à l'utilisateur
    @chat = if params[:chat_id].present?
              current_user.chats.find(params[:chat_id])
            else
              current_user.chats.build
            end

    # Crée le message associé au chat
    @message = @chat.messages.build(message_params)

    # Définir le titre du chat si nécessaire (nouveau chat ou titre vide)
    if @chat.new_record? || @chat.title.blank?
      @chat.title = @message.content.truncate(50)
    end

    # Sauvegarde le chat et le message
    @chat.save!
    @message.save!

    # Redirige vers le chat créé ou existant
    redirect_to root_path(chat_id: @chat.id)
  end

  private

  # ===========================
  # Paramètres autorisés pour le message
  # ===========================
  def message_params
    params.require(:message).permit(:content, :role)
  end
end
