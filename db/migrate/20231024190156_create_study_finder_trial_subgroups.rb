class CreateStudyFinderTrialSubgroups < ActiveRecord::Migration[7.0]
  def change
    create_table :study_finder_trial_subgroups do |t|
      t.references :subgroup, null: false, foreign_key: {to_table: :study_finder_subgroups}
      t.references :trial, null: false, foreign_key: {to_table: :study_finder_trials}

      t.timestamps
    end
  end
end
