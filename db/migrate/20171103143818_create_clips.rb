class CreateClips < ActiveRecord::Migration[5.1]
  def change
    create_table :clips do |t|
      t.string :name
      t.belongs_to :draw, index: true, null: false
      t.timestamps
    end
    add_reference :groups, :clip, foreign_key: true, null: true
  end
end
