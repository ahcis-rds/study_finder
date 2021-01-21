class CreateApiKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :token

      t.timestamps
    end
  end
end
