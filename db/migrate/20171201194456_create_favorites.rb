class CreateFavorites < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites do |t|
    	t.belongs_to :group, index: true, foreign_key: true, null: false
    	t.belongs_to :suite, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
