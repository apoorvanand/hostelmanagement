namespace :db do
  desc 'dump the correct schema.rb'
  task :switch_schema do
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
    ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
    # ActiveRecord::Base.connection.execute 'ALTER SCHEMA shared OWNER TO postgres;'

    # binding.pry
    # Apartment.connection.schema_search_path = "shared, \"$user\", public"
    ActiveRecord::Base.connection.schema_search_path = 'shared'
    load(Rails.root.join('db', 'schema.rb'))
    ActiveRecord::Base.connection.schema_search_path = 'public'
    # Apartment.connection.schema_search_path = "shared, \"$user\", public"
    # load(Rails.root.join('db', 'schema.rb'))
    #binding.pry
  end
end

Rake::Task["db:create"].enhance do
  Rake::Task["db:switch_schema"].invoke
end

# Rake::Task["db:schema:load"].enhance [:switch_schema]
