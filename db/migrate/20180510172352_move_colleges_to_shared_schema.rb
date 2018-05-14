class MoveCollegesToSharedSchema < ActiveRecord::Migration[5.1]
  def change

    reversible do |dir|
      dir.up do
        schema_name = ActiveRecord::Base.connection.schema_search_path.delete('\\"')
        if ActiveRecord::Base.connection.schema_search_path == '"public"'
          puts "in public schema"
          exec_query('INSERT INTO shared.colleges '\
                     'SELECT * '\
                     'FROM public.colleges;')
          # exec_query('TRUNCATE public.colleges;')
        else
          puts "not in public schema"
        end

        # add_reference :users, "shared.colleges", column: 'college_id'


        # exec_query('INSERT INTO shared.users '\
        #            'SELECT * '\
        #            'FROM users '\
        #            'ON CONFLICT DO NOTHING;')
        #
        # exec_query('ALTER TABLE shared.users '\
        #            'ADD CONSTRAINT users_college_id_fk '\
        #            'FOREIGN KEY ("college_id") '\
        #            'REFERENCES "shared.colleges" ("id") '\
        #            'ON CONFLICT DO NOTHING;')
      end

      dir.down do
        # raise ActiveRecord::IrreversibleMigration
        remove_reference :users, :colleges, foreign_key: true
        if ActiveRecord::Base.connection.schema_search_path == '"shared"'
          puts "in shared schema"
          exec_query('INSERT INTO public.colleges '\
                     'SELECT * '\
                     'FROM shared.colleges;')
          # exec_query('TRUNCATE shared.colleges;')
        else
          puts "not in shared schema"
        end
      end
    end

  end
end
