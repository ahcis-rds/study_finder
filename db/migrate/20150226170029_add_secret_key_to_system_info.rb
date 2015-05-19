class AddSecretKeyToSystemInfo < ActiveRecord::Migration
  def change
    add_column :study_finder_system_infos, :secret_key, :string
  end
end
