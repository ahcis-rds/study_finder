class Site < ApplicationRecord
  self.table_name = 'study_finder_sites'

  validates :site_name, presence: true

  has_many :trial_sites, dependent: :delete_all 
end