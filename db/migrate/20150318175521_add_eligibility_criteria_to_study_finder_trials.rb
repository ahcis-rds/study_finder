class AddEligibilityCriteriaToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :eligibility_criteria, :text
  end
end
