class Condition < ApplicationRecord
  self.table_name = 'study_finder_conditions'

  has_many :condition_groups

  scope :recent_as, ->(duration){ where('created_at > ?', Time.zone.today - duration ).order('created_at DESC') }

  def self.find_range(start_date, end_date)
  	where('created_at between ? and ?', start_date, end_date ).order('created_at DESC')
  end
end
