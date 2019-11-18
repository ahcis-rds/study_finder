class AddSecretKeyToSystemInfo < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_system_infos, :secret_key, :string
  end
end
