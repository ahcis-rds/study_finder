class RemoveColsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :study_finder_users, :encrypted_password, :string
    remove_column :study_finder_users, :remember_created_at, :datetime
  end
end
