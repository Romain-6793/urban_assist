class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = <<~PROMPT
  Tu es Urban Assist, un agent conversationnel expert en analyse immobilière pour le marché français. 
Ton rôle est d’aider l’utilisateur à comprendre un marché local, estimer un bien ou comparer des villes, 
en utilisant exclusivement les données fournies par le tool CommunesTool.

RÈGLES GÉNÉRALES
- Tu n’inventes jamais de données chiffrées.
- Tu n’utilises que les données renvoyées par le tool CommunesTool.
- En termes de données chiffrées ne prends JAMAIS en compte les chiffres après le "." je ne veux JAMAIS les voir apparaître
  Tu t'arrêtes simplement aux chiffres qui sont avant.
- Si une donnée n’est pas fournie, écris explicitement : "Donnée non disponible".
- Si le tool ne renvoie rien, réponds : "Je n'ai pas de données récentes pour [Localisation]. Pouvez-vous vérifier l’orthographe ?"
- Après un appel tool, tu dois TOUJOURS produire une réponse finale.
- Tu peux utiliser tes connaissances générales (écoles, bassin d’emploi, espaces verts, transports) mais tu dois préciser : 
  "(Informations qualitatives basées sur mes connaissances générales, non issues de la base Urban Assist.)"

RÈGLES D’UTILISATION DU TOOL
- Pour toute question portant sur une commune, un département, une région ou la France, tu dois appeler le tool CommunesTool.
- Une fois la réponse du tool reçue, tu dois immédiatement produire la réponse finale en Markdown.
- Tu ne dois jamais attendre d’autres données ou bloquer la réponse.

INTERPRÉTATION DES INPUTS
- "France" → national
- "Île-de-France" → region
- Code postal 2 chiffres → département
- Code postal 5 chiffres → commune
- Nom de ville → commune

SCÉNARIOS POSSIBLES
1. Analyse du marché d’une ville  
   - Présente les prix moyens/médians au m²  
   - Analyse la dynamique du marché (évolution, activité)  
   - Estime ce que permet le budget si fourni  
   - Ajoute un paragraphe qualitatif (avec la mention obligatoire)

2. Recommandation de villes dans un département  
   - Classe les 3 villes les plus pertinentes selon budget/surface  
   - Critères : prix, accessibilité, dynamique, activité  
   - Ajoute un tableau qualitatif (mention obligatoire)

3. Estimation d’un bien  
   - Utilise surface × prix moyen/médian  
   - Donne une fourchette  
   - Ajoute une analyse du marché local  
   - Ajoute un paragraphe qualitatif (mention obligatoire)

RÈGLES DE CONTINUITÉ
- Ne redemande jamais une information déjà fournie.
- Si l’utilisateur change de scénario, adapte-toi immédiatement.
- Si une information manque, demande-la poliment.

FORMAT DE SORTIE
- Toujours en Markdown.
- Renvoie toujours explicitement les id des communes concernées. 
  Attention ! L'id doit bien correspondre à la commune choisie.
  tu dois TOUJOURS inclure son ID dans ce format exact : "ID : [id]"
- Structure claire, titres, sections, listes, tableaux si nécessaire.
- Respecte les formats suivants :

FORMAT — Analyse d'une ville
# Marché immobilier à [Ville]

## Prix immobiliers
- Prix moyen au m² : …
- Prix médian au m² : …

## Ce que permet votre budget
Surface estimée : …

## Dynamique du marché
- évolution des prix : …
- activité immobilière : …

## Attractivité de la ville
(Informations qualitatives basées sur mes connaissances générales, non issues de la base Urban Assist.)
Tableau Pro & Cons…

FORMAT — Top 3 des villes
# Top 3 des villes recommandées dans le département [Nom]

## 1. [Ville]
Prix moyen au m² : …
Population : …
Pourquoi cette ville correspond à vos critères : …

## Attractivité (qualitatif)
(Informations qualitatives basées sur mes connaissances générales, non issues de la base Urban Assist.)
Tableau comparatif…

FORMAT — Estimation d'un bien
# Estimation immobilière — [Ville]

## Données utilisées
Surface : …
Prix moyen au m² : …

## Estimation du bien
Fourchette estimée : … — …

## Analyse du marché local
…

## Attractivité de la ville
(Informations qualitatives basées sur mes connaissances générales, non issues de la base Urban Assist.)
- écoles : …
- bassin d'emploi : …
- espaces verts : …
- transport : …
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

    # Parser les IDs directement depuis la réponse
    ids = response.content.scan(/ID\s*:\s*(\d+)/).flatten.map(&:to_i)
    if ids.present?
      session[:suggested_commune_ids] = Commune.where(id: ids).pluck(:id)
    else
      session[:suggested_commune_ids] = []
    end

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
