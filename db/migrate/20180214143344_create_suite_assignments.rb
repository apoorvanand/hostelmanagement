class CreateSuiteAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :room_assignments do |t|
      t.belongs_to :room, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
    end

    remove_reference :users, :room, foreign_key: true
  end
end
