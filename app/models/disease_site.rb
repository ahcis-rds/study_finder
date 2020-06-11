class DiseaseSite < ApplicationRecord
  self.table_name = 'study_finder_disease_sites'

  belongs_to :group

  def disease_site_label
    unless group.nil?
      return "#{disease_site_name} (#{group.group_name})"
    else
      return disease_site_name
    end
  end
end