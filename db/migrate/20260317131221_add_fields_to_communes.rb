class AddFieldsToCommunes < ActiveRecord::Migration[7.1]
  def change
    add_column :communes, :avg_rent_sqm, :float
    add_column :communes, :rent_quality, :float
    add_column :communes, :nb_obs_commune, :float
  end
end
