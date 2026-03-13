class CreateCommunes < ActiveRecord::Migration[7.1]
  def change
    create_table :communes do |t|
      t.string :insee_code
      t.string :name
      t.string :department
      t.string :region
      t.integer :population
      t.decimal :avg_price_sqm
      t.decimal :median_price_sqm
      t.integer :total_transactions
      t.integer :transactions_last_year
      t.decimal :price_evolution_1y
      t.decimal :price_evolution_3y
      t.date :last_updated

      t.timestamps
    end
  end
end
