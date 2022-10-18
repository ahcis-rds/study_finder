class CreateApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :approvals do |t|
      t.integer :trial_id
      t.integer :user_id
      t.boolean :approved,  :null => false, :default => false
      t.timestamps 
    end
  end
end
