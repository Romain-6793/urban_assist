class CommunesTool < RubyLLM::Tool
  description "Récupère des données de loyers depuis la table communes"

  param :zone_type, desc: "commune, departement, region ou national"
  param :zone_name, desc: "Nom de la zone (optionnel)", required: false

  # IMPORTANT : Il faut l'extension postgresql "unaccent"

  def execute(zone_type:, zone_name: nil)

    # Le scope est défini par l'input utilisateur, le LLM détecte les mots et sait comment 
    # chercher
    # La limit des first(15) est une contrainte technique, si on le laisse chercher partout
    # Le nombre de tokens de 8000 max par requête est très vite dépassé

    scope =
      case zone_type
      when "commune"
        Commune.where("unaccent(lower(name)) = unaccent(lower(?))", zone_name).first ||
        Commune.where("unaccent(lower(name)) LIKE unaccent(lower(?))", "%#{zone_name}%").first
      when "department", "departement"
        Commune.where("unaccent(lower(department)) = unaccent(lower(?))", zone_name).first(15) ||
        Commune.where("unaccent(lower(department)) LIKE unaccent(lower(?))", "%#{zone_name}%").first(15)
      when "region"
        Commune.where("unaccent(lower(region)) = unaccent(lower(?))", zone_name).first(15) ||
        Commune.where("unaccent(lower(region)) LIKE unaccent(lower(?))", "%#{zone_name}%").first(15)
      when "national"
        Commune.all.first(15)
      else
        return { error: "zone_type invalide" }
      end

      # Si rien trouvé
    if scope.blank?
      Rails.logger.info("📊 Aucune donnée trouvée pour #{zone_type} / #{zone_name}")
      return { data: [] }
    end

     # Normalisation : on renvoie toujours un tableau de hashes
    records = scope.is_a?(Commune) ? [scope] : scope

    # Le hash final, résultat de l'itération sur la db

    data = records.map do |c|
      {
        id: c.id,
        name: c.name,
        department: c.department,
        region: c.region,
        insee_code: c.insee_code,
        avg_price_sqm: c.avg_price_sqm,
        median_price_sqm: c.median_price_sqm,
        total_transactions: c.total_transactions,
        transactions_last_year: c.transactions_last_year,
        price_evolution_1y: c.price_evolution_1y,
        price_evolution_3y: c.price_evolution_3y,
        avg_rent_sqm: c.avg_rent_sqm,
        rent_quality: c.rent_quality,
        nb_obs_commune: c.nb_obs_commune
      }
    end

    # On logue pour bien s'assurer que le LLM a fait appel à la DB

    Rails.logger.info("📊 Résultat: #{data}")
    
    # On lui retourne la data demandée

    return {
      "data" => data
    }
  end
end