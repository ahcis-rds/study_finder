class AddEligibilityCriteriaToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :eligibility_criteria, :text
  end
end
