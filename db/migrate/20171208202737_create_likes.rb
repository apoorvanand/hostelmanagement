class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
			t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :favorite, index: true, foreign_key: true, null:false
      t.timestamps
    end
  end
end
