class RemoveVwGroupTrialCounts < ActiveRecord::Migration[5.2]
  def up
  	execute "DROP VIEW vw_study_finder_trial_counts"
    execute "DROP VIEW vw_study_finder_trial_gp_name"
  end

  def down
    adapter = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
    if adapter == :oracleenhanced
      # This is an oracle thing.  Oracle doesn't support boolean types. If you are not using oracle, please remove this sillyness and just use visible = true.
      visible = 1
    else
      # We are using postgres locally, which supports a boolean type.
      visible = true
    end


    execute "CREATE VIEW vw_study_finder_trial_gp_name AS SELECT
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
                  trials.id"

    execute "CREATE VIEW vw_study_finder_trial_counts AS
      SELECT x.id, x.group_name, count(x.trial_ids) as trial_count
      FROM vw_study_finder_trial_gp_name x
      GROUP BY x.id, x.group_name
    "
  end
end
