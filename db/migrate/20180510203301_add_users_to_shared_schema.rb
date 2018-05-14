class AddUsersToSharedSchema < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        remove_foreign_key "users", "rooms"
        exec_query("ALTER TABLE shared.users "\
                   "ADD COLUMN IF NOT EXISTS "\
                   "college_id INTEGER"

        )
        # add_reference :users, :colleges, column: :college_id
        college_name = ActiveRecord::Base.connection.schema_search_path.delete('\\"')
        college_id = exec_query("SELECT id "\
                                "FROM shared.colleges "\
                                "WHERE subdomain='#{college_name}'")
        puts college_id
        id = college_id.rows&.first
        if id.present?
          exec_query("ALTER TABLE users "\
                     "ADD COLUMN college_id "\
                     "INTEGER DEFAULT #{id}")
        else
          exec_query("ALTER TABLE users "\
                     "ADD COLUMN college_id "\
                     "INTEGER")
        end
        exec_query("INSERT INTO shared.users SELECT * FROM #{college_name}.users")
        add_foreign_key :memberships, "shared.users", column: :user_id
        #add_reference :users, :colleges, column: :college_id, foreign_key: true
        add_foreign_key :users, :colleges, column: :college_id
      end
    end
  end
end
