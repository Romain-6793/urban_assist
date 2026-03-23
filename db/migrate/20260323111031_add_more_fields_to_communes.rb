class AddMoreFieldsToCommunes < ActiveRecord::Migration[7.1]
  def change
    add_column :communes, :population, :integer
    add_column :communes, :superficie_km2, :float
    add_column :communes, :densite, :integer
    add_column :communes, :altitude_moyenne, :integer
    add_column :communes, :altitude_minimale, :integer
    add_column :communes, :altitude_maximale, :integer
    add_column :communes, :latitude_mairie, :float
    add_column :communes, :longitude_mairie, :float
    add_column :communes, :latitude_centre, :float
    add_column :communes, :longitude_centre, :float
    add_column :communes, :niveau_equipements_services, :integer
    add_column :communes, :url_wikipedia, :string
    add_column :communes, :url_villedereve, :string
  end
end
