class ChangeUserRoomForeignKey < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key "users", "rooms"
    add_foreign_key :memberships, "public.users", column: :user_id
  end
end
