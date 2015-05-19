class VwGroupTrialCounts < ActiveRecord::Migration
  def up
    if Rails.env == 'local'
      # We are using postgres locally, which supports a boolean type.
      visible = true
    else
      # This is an oracle thing.  Oracle doesn't support boolean types. If you are not using oracle, please remove this sillyness and just use visible = true.
      visible = 1
    end

    execute "CREATE VIEW vw_study_finder_trial_counts AS
      SELECT x.id, x.group_name, count(x.trial_ids) as trial_count
      FROM
      (
              SELECT
                  g.id,
                  g.group_name,
                  trials.id as trial_ids
              FROM study_finder_groups g
                LEFT JOIN study_finder_condition_groups condition_groups ON condition_groups.group_id = g.id
                LEFT JOIN study_finder_trial_conditions trial_conditions ON trial_conditions.condition_id = condition_groups.condition_id
                LEFT JOIN study_finder_trials trials ON trials.id = trial_conditions.trial_id AND trials.visible = #{visible}
              GROUP BY
                  g.id,
                  g.group_name,
                  trials.id
      ) x
      GROUP BY x.id, x.group_name
    "
  end

  def down
    execute "DROP VIEW vw_study_finder_trial_counts"
  end
end
