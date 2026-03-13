class CreateFavorites < ActiveRecord::Migration[7.1]
  def change
    create_table :favorites do |t|
      t.text :note
      t.references :chat, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true

      t.timestamps
    end
  end
end
