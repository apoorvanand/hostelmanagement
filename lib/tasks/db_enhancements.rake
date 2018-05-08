namespace :db do
  desc 'dump the correct schema.rb'
  task :switch_schema do
    College.first.activate!
  end
end

Rake::Task["db:schema:dump"].enhance [:switch_schema]
