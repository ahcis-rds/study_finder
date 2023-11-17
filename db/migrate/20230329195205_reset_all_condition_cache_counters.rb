class ResetAllConditionCacheCounters < ActiveRecord::Migration[7.0]
  def up
    Condition.all.each do |c|
      Condition.reset_counters(c.id, :condition_groups)
    end
  end

  def down
    # no rollback needed
  end
end
