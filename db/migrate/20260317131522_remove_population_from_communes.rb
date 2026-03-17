class RemovePopulationFromCommunes < ActiveRecord::Migration[7.1]
  def change
    remove_column :communes, :population, :integer
  end
end
