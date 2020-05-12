class StudyFinder::Location < ApplicationRecord
  self.table_name = 'study_finder_locations'

  belongs_to :zip_centroid, foreign_key: 'zip', primary_key: 'zip'

  def coordinates
    [zip_centroid.lat, zip_centroid.long]
  end
end
