class Approval < ActiveRecord::Base
  self.table_name = 'approvals'

  belongs_to :trial

end