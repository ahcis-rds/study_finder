require "rails_helper"

describe Group do

  it "responds to a boolean method for condition_groups" do
    group = Group.create(children:true, group_name: 'test name')
    expect(group.conditions_empty?).to be_truthy
    condition = Condition.create
    cg = ConditionGroup.create(condition: condition, group: group)
    expect(group.conditions_empty?).to be_falsey
  end

  it "returns a hash of applicable boolean filters" do
    group = Group.create(children: true, adults: true, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = Group.create(children: false, adults: true, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).not_to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = Group.create(children: true, adults: false, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).not_to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = Group.create(children: true, adults: true, healthy_volunteers: false, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).not_to eq(1)
  end

  it "returns accurate count of trials which reference this group" do
    group = Group.create(group_name: 'test name')
    expect(group.study_count).to eq(0)
    condition = Condition.create
    # Non-visible trial
    t0 = Trial.create(visible: false)
    tc = TrialCondition.create(trial: t0, condition: condition)
    cg = ConditionGroup.create(condition: condition, group: group, trial_condition: tc)
    expect(group.study_count).to eq(0)
    # First trial
    t = Trial.create(visible: true)
    tc = TrialCondition.create(trial: t, condition: condition)
    cg = ConditionGroup.create(condition: condition, group: group, trial_condition: tc)
    expect(group.study_count).to eq(1)
    # Separate but duplicated trial condition, same trial
    tc1 = TrialCondition.create(trial: t, condition: condition)
    cg = ConditionGroup.create(condition: condition, group: group, trial_condition: tc1)
    expect(group.study_count).to eq(1)
    # Second trial
    t2 = Trial.create(visible: true)
    tc2 = TrialCondition.create(trial: t2, condition: condition)
    cg2 = ConditionGroup.create(condition: condition, group: group, trial_condition: tc2)
    expect(group.study_count).to eq(2)
  end

end
