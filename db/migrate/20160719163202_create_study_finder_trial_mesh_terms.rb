class CreateStudyFinderTrialMeshTerms < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trial_mesh_terms do |t|
      t.integer :trial_id
      t.string :mesh_term_type
      t.string :mesh_term

      t.timestamps
    end
  end
end
