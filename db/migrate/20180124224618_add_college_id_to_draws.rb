class AddCollegeIdToDraws < ActiveRecord::Migration[5.1]
  def change
    add_reference :draws, :college, foreign_key: true

    reversible do |dir|
      # add the right foreign key to the existing tables
      dir.up do
        subdomain = execute('SHOW search_path;').first['search_path'].split(',').first
        return if subdomain == 'public' # I don't like this
        Rails.logger.info "subdomain = '#{subdomain}"
        execute('SET search_path TO public;')
        c_query = "SELECT * FROM colleges WHERE subdomain = '#{subdomain}';"
        college_id = execute(c_query).first['id']
        execute("SET search_path TO #{subdomain};");

        execute('SELECT * FROM draws;').each do |d|
          time = Time.now.utc.strftime('%F %T')
          execute <<-SQL
            UPDATE draws SET college_id = '#{college_id}',
                             updated_at = '#{time}'
                         WHERE draws.id = #{d['id']};
          SQL
        end
      end
    end

    change_column_null :draws, :college_id, false
  end
end
