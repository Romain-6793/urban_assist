#seedd d'import de données csv DVF

require 'csv'

# on commence par nettoyer la tabll > éviter les doublons
Commune.destroy_all

# Import depuis le CSV, attention ce fichier doit etre à la racine du projet !
# NB : il faudra peut être ajuster les noms de champs en fonction de ce que lo'n garde ou ajoute
CSV.foreach(Rails.root.join('communes_22_24_achat_locatif.csv'), headers: true, header_converters: :symbol) do |row|
  Commune.create!(
    insee_code: row[:insee_code],
    name: row[:name],
    department: row[:department],
    region: row[:region],
    avg_price_sqm: row[:avg_price_sqm]&.to_f,
    median_price_sqm: row[:median_price_sqm]&.to_f,
    total_transactions: row[:total_transactions]&.to_i,
    transactions_last_year: row[:transactions_last_year]&.to_i,
    price_evolution_1y: row[:price_evolution_1y]&.to_f,
    price_evolution_3y: row[:price_evolution_3y]&.to_f,
    avg_rent_sqm: row[:avg_rent_sqm]&.to_f,
    rent_quality: row[:rent_quality]&.to_f,
    nb_obs_commune: row[:nb_obs_commune]&.to_f,
    last_updated: Date.today
  )
end

puts "Import terminé !"
puts "Il y a 32677 communes dans le fichier CSV original"
#un petit count histoire de vérifier si les communes st importés correctement
puts "#{Commune.count} importés dans la db"
