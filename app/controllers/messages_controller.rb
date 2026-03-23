class MessagesController < ApplicationController
  before_action :authenticate_user!

SYSTEM_PROMPT = <<~PROMPT
Tu es Urban Assist, expert en immobilier français.

RÈGLE FONDAMENTALE : Utilise UNIQUEMENT les données de CommunesTool pour les chiffres.
Si CommunesTool ne renvoie rien, indique-le poliment.

DÉTECTION AUTOMATIQUE :
- Budget mensuel → location (avg_rent_sqm)
- Budget total/prix au m² → achat (median_price_sqm)

DÉTECTION DU TYPE DE RECHERCHE :
- Si l'utilisateur dit "acheter" + budget mensuel → Calculer budget total = budget_mensuel × 12 × 25 (prêt 25 ans)
- Si l'utilisateur dit "mois" + "acheter" → C'est un achat, utiliser median_price_sqm
- Si l'utilisateur donne budget mensuel sans "acheter" → Supposer location, utiliser avg_rent_sqm

CALCULS AUTOMATIQUES :
- Recherche ACHAT : Budget_total / median_price_sqm = surface possible
- Recherche LOCATION : Budget_mensuel / avg_rent_sqm = surface possible
- TOUJOURS utiliser le bon champ selon le type de recherche

FORMAT :
- Liste les communes : "- [NOM] (ID : [id])"
- Pas de tableaux Markdown complexes
- Structure claire avec titres

Pour les infos qualitatives (écoles, transports...), précise :
"(Informations générales, non issues de la base de données)"
PROMPT

  # ===========================
  def create
    #Définition d'un système PROMPT
  # Crée un nouveau message
  # ===========================

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
    @message.role = "user"

    # Définir le titre du chat si nécessaire (nouveau chat ou titre vide)
    if @chat.new_record? || @chat.title.blank?
      @chat.title = @message.content.truncate(50)
    end

    # Sauvegarde le chat et le message
    @chat.save! if @chat.new_record?
    @message.save!

    # Ici on précise bien la méthode with_tools avec notre CommunesTool en argument
    # ça va permettre au LLM d'interroger notre db de Communes.

    @ruby_llm_chat = RubyLLM.chat.with_tools(CommunesTool)

    build_conversation_history
    response = @ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)

    # if response.tool_calls.nil? || response.tool_calls.empty?
    #   raise "Le LLM n'a pas utilisé le tool"
    # end

    @chat.messages.create!(
    content: response.content,
    role: "assistant"
    )

    # Parser les IDs depuis les tool_calls ET depuis le texte (double sécurité)
    commune_ids = []
    
    # Méthode 1 : Extraire depuis les tool_calls (plus fiable)
    if response.tool_calls.present?
      Rails.logger.info("🔧 Tool calls présents : #{response.tool_calls.count}")
      commune_ids = response.tool_calls
        .select { |tc| tc.tool_name == "CommunesTool" }
        .flat_map { |tc| tc.result.dig("data")&.map { |c| c["id"] } }
        .compact
      Rails.logger.info("🔧 IDs extraits des tool_calls : #{commune_ids}")
    end
    
    # Méthode 2 : Parser depuis le texte (fallback)
    if commune_ids.empty?
      commune_ids = response.content.scan(/\(ID\s*:\s*(\d+)\)/).flatten.map(&:to_i)
      Rails.logger.info("🔧 IDs extraits du texte : #{commune_ids}")
    end
    
    session[:suggested_commune_ids] = commune_ids.present? ? Commune.where(id: commune_ids).pluck(:id) : []
    Rails.logger.info("🔧 IDs stockés en session : #{session[:suggested_commune_ids]}")

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

# Méthode pour itérer sur les messages existants et les donner au LLM
def build_conversation_history
  @chat.messages.where.not(id: @message.id).each do |message|
    @ruby_llm_chat.add_message(message)
  end
end
