class RemoveVwStudyFinderTrialGroups < ActiveRecord::Migration[5.2]
  def up
    execute "drop view vw_study_finder_trial_groups"
  end

  def down
    execute "create view vw_study_finder_trial_groups as
    select study_finder_trial_conditions.trial_id, study_finder_condition_groups.group_id
    from study_finder_condition_groups
    inner join study_finder_trial_conditions on study_finder_trial_conditions.condition_id = study_finder_condition_groups.condition_id
    group by study_finder_trial_conditions.trial_id, study_finder_condition_groups.group_id"
  end
end
