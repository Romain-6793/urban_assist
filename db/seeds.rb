require 'csv'

# on convertit les decimaux à virgules en format avec . (pour ruby)
def parse_french_decimal(value)
  return nil if value.nil? || value.strip.empty?
  value.gsub(',', '.').to_f
end

# Nettoyage des tables (c'est beintôt le printemps ;-) )
puts "Un petit coup de propre des données existantes..."
Favorite.destroy_all
Commune.destroy_all

# Import depuis le nouveau CSV avec séparateur ";"
csv_path = Rails.root.join('communes_22_24_achat_locatif_insee.csv')

CSV.foreach(csv_path, headers: true, col_sep: ';', header_converters: :symbol, encoding: 'ISO-8859-1:UTF-8') do |row|
  Commune.create!(
    insee_code: row[:insee_code],
    name: row[:name],
    department: row[:dep_code],
    region: row[:reg_nom],
    avg_price_sqm: parse_french_decimal(row[:avg_price_sqm]),
    median_price_sqm: parse_french_decimal(row[:median_price_sqm]),
    total_transactions: row[:total_transactions]&.to_i,
    transactions_last_year: row[:transactions_last_year]&.to_i,
    price_evolution_1y: parse_french_decimal(row[:price_evolution_1y]),
    price_evolution_3y: parse_french_decimal(row[:price_evolution_3y]),
    avg_rent_sqm: row[:avg_rent_sqm]&.to_f,
    rent_quality: row[:rent_quality]&.to_f,
    nb_obs_commune: row[:nb_obs_commune]&.to_f,
    population: row[:population]&.to_i,
    superficie_km2: row[:superficie_km2]&.to_f,
    densite: row[:densite]&.to_i,
    altitude_moyenne: row[:altitude_moyenne]&.to_i,
    altitude_minimale: row[:altitude_minimale]&.to_i,
    altitude_maximale: row[:altitude_maximale]&.to_i,
    latitude_mairie: parse_french_decimal(row[:latitude_mairie]),
    longitude_mairie: parse_french_decimal(row[:longitude_mairie]),
    latitude_centre: parse_french_decimal(row[:latitude_centre]),
    longitude_centre: parse_french_decimal(row[:longitude_centre]),
    niveau_equipements_services: row[:niveau_equipements_services]&.to_i,
    url_wikipedia: row[:url_wikipedia],
    url_villedereve: row[:url_villedereve],
    last_updated: Date.today
  )
end

puts "Import terminé"
puts "Vous devriez avoir 4766 communes logiquement (enfin espérons hein ! lol)"
puts "#{Commune.count} communes importées dans la base de données"
