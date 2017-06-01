class StudyFinder::Condition < ActiveRecord::Base
  self.table_name = 'study_finder_conditions'

  scope :recent_as, ->(duration){ where('created_at > ?', Time.zone.today - duration ).order('created_at DESC') }

end
