class CreateBlueprints < ActiveRecord::Migration[5.1]
  def change
    create_table :blueprints do |t|
      t.string :building
      t.string :name
      t.integer :size
      t.string :rooms

      t.timestamps
    end
  end
end
