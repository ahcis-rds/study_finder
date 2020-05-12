class CreateZipCentroids < ActiveRecord::Migration[5.2]
  def change
    create_table :zip_centroids do |t|
      t.string :zip, limit: 5
      t.decimal :lat, precision: 9, scale: 6
      t.decimal :long, precision: 9, scale: 6
    end
  end
end
