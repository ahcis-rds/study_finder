class Location < ApplicationRecord
  self.table_name = 'study_finder_locations'

  def as_json(options = {})
    {
      name: location,
      city: city,
      state: state,
      zip: zip,
      country: country
    }
  end
end
