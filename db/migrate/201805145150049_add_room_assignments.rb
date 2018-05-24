class AddRoomAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :room_assignments do |t|
      t.references :user, foreign_key: true, null: false, index: true
      t.references :room, foreign_key: true, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        exec_query('INSERT INTO room_assignments (user_id, room_id) '\
                    'SELECT id, room_id '\
                    'FROM users '\
                    'WHERE room_id IS NOT NULL;')
      end

      dir.down do
        exec_query('INSERT INTO users (room_id) '\
                   'SELECT room_id '\
                   'FROM room_assignments '\
                   'WHERE users.id = room_assignments.user_id;')
      end
    end

    remove_reference :users, :room, foreign_key: true
  end
end
