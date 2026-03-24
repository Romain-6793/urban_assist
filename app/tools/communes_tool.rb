class CommunesTool < RubyLLM::Tool
  # Mapping nom de département → code
  DEPARTMENT_MAPPING = {
    "ain" => "01", "aisne" => "02", "allier" => "03", "alpes-de-haute-provence" => "04",
    "hautes-alpes" => "05", "alpes-maritimes" => "06", "ardeche" => "07", "ardennes" => "08",
    "ariege" => "09", "aube" => "10", "aude" => "11", "aveyron" => "12",
    "bouches-du-rhone" => "13", "calvados" => "14", "cantal" => "15", "charente" => "16",
    "charente-maritime" => "17", "cher" => "18", "correze" => "19", "corse-du-sud" => "2A",
    "haute-corse" => "2B", "cote-d-or" => "21", "cotes-d-armor" => "22", "creuse" => "23",
    "dordogne" => "24", "doubs" => "25", "drome" => "26", "eure" => "27",
    "eure-et-loir" => "28", "finistere" => "29", "gard" => "30", "haute-garonne" => "31",
    "gers" => "32", "gironde" => "33", "herault" => "34", "ille-et-vilaine" => "35",
    "indre" => "36", "indre-et-loire" => "37", "isere" => "38", "jura" => "39",
    "landes" => "40", "loir-et-cher" => "41", "loire" => "42", "haute-loire" => "43",
    "loire-atlantique" => "44", "loiret" => "45", "lot" => "46", "lot-et-garonne" => "47",
    "lozere" => "48", "maine-et-loire" => "49", "manche" => "50", "marne" => "51",
    "haute-marne" => "52", "mayenne" => "53", "meurthe-et-moselle" => "54", "meuse" => "55",
    "morbihan" => "56", "moselle" => "57", "nievre" => "58", "nord" => "59",
    "oise" => "60", "orne" => "61", "pas-de-calais" => "62", "puy-de-dome" => "63",
    "pyrenees-atlantiques" => "64", "hautes-pyrenees" => "65", "pyrenees-orientales" => "66",
    "bas-rhin" => "67", "haut-rhin" => "68", "rhone" => "69", "haute-saone" => "70",
    "saone-et-loire" => "71", "sarthe" => "72", "savoie" => "73", "haute-savoie" => "74",
    "paris" => "75", "seine-maritime" => "76", "seine-et-marne" => "77", "yvelines" => "78",
    "deux-sevres" => "79", "somme" => "80", "tarn" => "81", "tarn-et-garonne" => "82",
    "var" => "83", "vaucluse" => "84", "vendee" => "85", "vienne" => "86",
    "haute-vienne" => "87", "vosges" => "88", "yonne" => "89", "territoire-de-belfort" => "90",
    "essonne" => "91", "hauts-de-seine" => "92", "seine-saint-denis" => "93",
    "val-de-marne" => "94", "val-d-oise" => "95", "guadeloupe" => "971",
    "martinique" => "972", "guyane" => "973", "la-reunion" => "974", "mayotte" => "976"
  }.freeze

  description <<~DESC
    Récupère des données immobilières enrichies depuis la table communes.
    
    IMPORTANT - FORMAT DES PRIX :
    - avg_price_sqm et median_price_sqm sont en EUROS par m² (nombre entier)
    - Afficher SANS virgule de séparation des milliers
    - Exemple : 3580 €/m² (PAS 3,580 €/m²)
    - price_evolution_1y et price_evolution_3y sont en pourcentage
    
    CHAMPS DISPONIBLES DANS LA BASE :
    
    Données immobilières :
    - avg_price_sqm : Prix moyen au m² (en €) - POUR ACHAT
    - median_price_sqm : Prix médian au m² (en €) - POUR ACHAT
    - total_transactions : Nombre total de transactions immobilières
    - transactions_last_year : Nombre de transactions sur la dernière année
    - price_evolution_1y : Évolution des prix sur 1 an (en %)
    - price_evolution_3y : Évolution des prix sur 3 ans (en %)
    - avg_rent_sqm : Loyer moyen au m² (en €/ mois) - POUR LOCATION
    - rent_quality : Indice de qualité du loyer (0-1)
    - nb_obs_commune : Nombre d'observations pour la commune
    
    Données démographiques et géographiques :
    - population : Population totale de la commune
    - superficie_km2 : Superficie en km²
    - densite : Densité de population (hab/km²)
    - altitude_moyenne : Altitude moyenne (en mètres)
    - altitude_minimale : Altitude minimale (en mètres)
    - altitude_maximale : Altitude maximale (en mètres)
    - latitude_mairie : Latitude de la mairie
    - longitude_mairie : Longitude de la mairie
    - niveau_equipements_services : Niveau d'équipements (1-4)
    - url_wikipedia : Lien Wikipedia
    - url_villedereve : Lien villedereve.fr
    
    Données administratives :
    - insee_code : Code INSEE de la commune (identifiant unique)
    - name : Nom de la commune
    - department : Code du département (2 chiffres)
    - region : Nom de la région
    
    SÉLECTION DES COMMUNES :
    Pour les recherches par département ou région, retourne les 5 communes les PLUS PERTINENTES
    selon les critères suivants (par ordre de priorité) :
    1. Prix médian dans la fourchette demandée par l'utilisateur (si spécifié)
    2. Nombre de transactions élevé (marché actif)
    3. Évolution des prix favorable
    4. Qualité du loyer élevée (si recherche locative)
  DESC

  param :zone_type, desc: "commune, departement, region ou national"
  param :zone_name, desc: "Nom de la zone (optionnel)", required: false
  param :sort_by, desc: "Critère de tri : price_asc, price_desc, transactions, evolution (optionnel)", required: false
  param :min_population, desc: "Population minimum (optionnel)", required: false

  # IMPORTANT : Il faut l'extension postgresql "unaccent"

  def execute(zone_type:, zone_name: nil, sort_by: nil, min_population: nil)

    # Le scope est défini par l'input utilisateur, le LLM détecte les mots et sait comment chercher
    scope =
      case zone_type
      when "commune"
        Commune.where("unaccent(lower(name)) = unaccent(lower(?))", zone_name).first ||
        Commune.where("unaccent(lower(name)) LIKE unaccent(lower(?))", "%#{zone_name}%").first
      when "department", "departement"
        normalized_name = normalize_name(zone_name)
        Commune.where("unaccent(lower(department)) = unaccent(lower(?))", normalized_name).order("RANDOM()").limit(15) ||
        Commune.where("unaccent(lower(department)) LIKE unaccent(lower(?))", "%#{normalized_name}%").order("RANDOM()").limit(15)
      when "region"
        Commune.where("unaccent(lower(region)) = unaccent(lower(?))", zone_name).order("RANDOM()").limit(15) ||
        Commune.where("unaccent(lower(region)) LIKE unaccent(lower(?))", "%#{zone_name}%").order("RANDOM()").limit(15)
      when "national"
        Commune.order("RANDOM()").limit(15)
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

    # Filtrer par population si spécifié
    if min_population && !min_population.empty? && records.is_a?(ActiveRecord::Relation)
      records = records.where("population >= ?", min_population)
      Rails.logger.info("👥 Filtre population >= #{min_population} : #{records.count} communes")
    end

    # Pour les recherches multiples (département, région, national), on trie par pertinence
    if records.is_a?(ActiveRecord::Relation) && records.count > 1
      records = apply_smart_sorting(records, sort_by)
      # Limite à 5 communes les plus pertinentes
      records = records.limit(5)
    end

    # Le hash final, résultat de l'itération sur la db
    # Les prix sont convertis en entiers pour éviter les problèmes de formatage
    data = records.map do |c|
      {
        id: c.id,
        name: c.name,
        department: c.department,
        region: c.region,
        insee_code: c.insee_code,
        avg_price_sqm: c.avg_price_sqm&.round,
        median_price_sqm: c.median_price_sqm&.round,
        total_transactions: c.total_transactions,
        transactions_last_year: c.transactions_last_year,
        price_evolution_1y: c.price_evolution_1y&.round(2),
        price_evolution_3y: c.price_evolution_3y&.round(2),
        avg_rent_sqm: c.avg_rent_sqm&.round(2),
        rent_quality: c.rent_quality&.round(2),
        nb_obs_commune: c.nb_obs_commune&.round,
        population: c.population,
        superficie_km2: c.superficie_km2&.round(2),
        densite: c.densite,
        altitude_moyenne: c.altitude_moyenne,
        altitude_minimale: c.altitude_minimale,
        altitude_maximale: c.altitude_maximale,
        latitude_mairie: c.latitude_mairie&.round(6),
        longitude_mairie: c.longitude_mairie&.round(6),
        niveau_equipements_services: c.niveau_equipements_services,
        url_wikipedia: c.url_wikipedia,
        url_villedereve: c.url_villedereve
      }
    end

    # On logue pour bien s'assurer que le LLM a fait appel à la DB
    Rails.logger.info("📊 Résultat: #{data.count} commune(s) trouvée(s)")
    
    # On lui retourne la data demandée avec instructions de formatage
    return {
      "data" => data
    }
  end

  private

  def normalize_name(name)
    return name if name.nil? || name.empty?
    
    # Normaliser le nom (minuscules, sans accents)
    normalized = name.to_s.downcase.strip
    normalized = normalized.gsub(/[àáâãäå]/, 'a')
                           .gsub(/[èéêë]/, 'e')
                           .gsub(/[ìíîï]/, 'i')
                           .gsub(/[òóôõö]/, 'o')
                           .gsub(/[ùúûü]/, 'u')
                           .gsub(/[ç]/, 'c')
    
    # Retourner le code si trouvé, sinon le nom original
    DEPARTMENT_MAPPING[normalized] || name
  end

  def apply_smart_sorting(records, sort_by)
    # Tri intelligent selon le critère demandé ou par défaut
    case sort_by
    when "price_asc"
      records.order(median_price_sqm: :asc)
    when "price_desc"
      records.order(median_price_sqm: :desc)
    when "transactions"
      records.order(transactions_last_year: :desc)
    when "evolution"
      records.order(price_evolution_1y: :desc)
    else
      # Tri par défaut : communes avec le plus de transactions (marché actif)
      # puis par évolution positive des prix
      records
        .where.not(transactions_last_year: nil)
        .order(transactions_last_year: :desc)
        .order(price_evolution_1y: :desc)
    end
  end
end
