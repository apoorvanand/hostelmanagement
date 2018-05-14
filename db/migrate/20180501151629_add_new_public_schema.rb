class AddNewPublicSchema < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
    ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
    ActiveRecord::Base.connection.schema_search_path = 'shared'
    load(Rails.root.join('db', 'schema.rb'))
  end
end
