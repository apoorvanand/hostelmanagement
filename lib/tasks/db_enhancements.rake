# frozen_string_literal: true

namespace :db do
  desc 'dump the correct schema.rb'
  task :create_shared_schema do
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

Rake::Task['db:schema:load'].enhance [:create_shared_schema]
