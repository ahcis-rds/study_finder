class Approval < ApplicationRecord
  self.table_name = 'approvals'

  belongs_to :trial
  belongs_to :user

end