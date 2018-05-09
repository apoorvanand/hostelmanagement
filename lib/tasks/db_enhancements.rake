namespace :db do
  desc 'dump the correct schema.rb'
  task :switch_schema do
    # #connection.each{}
    # ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
    # ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
    # # ActiveRecord::Base.connection.execute 'ALTER SCHEMA shared OWNER TO postgres;'
    #
    # # binding.pry
    # # Apartment.connection.schema_search_path = "shared, \"$user\", public"
    # ActiveRecord::Base.connection.schema_search_path = 'shared'
    # load(Rails.root.join('db', 'schema.rb'))
    # # ActiveRecord::Base.connection.schema_search_path = 'public'
    # # Apartment.connection.schema_search_path = "shared, \"$user\", public"
    # # load(Rails.root.join('db', 'schema.rb'))
    # #binding.pry
    ActiveRecord::Base.configurations.each_value do |configuration|
      if configuration.key?("database")
        ActiveRecord::Base.establish_connection(configuration)
        ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
        ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
        ActiveRecord::Base.connection.schema_search_path = 'shared'
        load(Rails.root.join('db', 'schema.rb'))
      end
    end
  end
end

Rake::Task["db:create"].enhance do
  Rake::Task["db:switch_schema"].invoke
end

# Rake::Task["db:schema:load"].enhance [:switch_schema]
#
# def load_schema_current(format = ActiveRecord::Base.schema_format, file = nil, environment = env)
#   ActiveRecord::Base.configurations.each_value do |configuration|
#     ActiveRecord::Base.establish_connection(configuration.to_sym)
#     ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared;'
#     ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared to public;'
#     ActiveRecord::Base.connection.schema_search_path = 'shared'
#     load(Rails.root.join('db', 'schema.rb'))
#   end
#
# end
  # environments = [environment]
  # environments << "test" if environment == "development"
