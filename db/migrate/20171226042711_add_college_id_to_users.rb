class AddCollegeIdToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :college, :string
    add_reference :users, :college, foreign_key: true
  end
end
