class StudyFinder::User < ActiveRecord::Base
  self.table_name = 'study_finder_users'

  def full_name
    "#{self.first_name} #{self.last_name}".html_safe
  end
end