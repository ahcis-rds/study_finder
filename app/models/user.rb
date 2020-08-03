class User < ApplicationRecord
  self.table_name = 'study_finder_users'

  validates :first_name, :last_name, :email, :internet_id, presence: true
  validates :email, :internet_id, uniqueness: true
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  def full_name
    "#{self.first_name} #{self.last_name}".html_safe
  end
end