class CreateStudyFinderTrialInterventions < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trial_intervents do |t|
      t.integer :trial_id

      t.string :intervention_type
      t.string :intervention
      t.string :description, limit: 4000
      t.timestamps
    end
  end
end
