require "rails_helper"

describe Group do

  it "responds to a boolean method for condition_groups" do
    group = create(:group, children:true, group_name: 'test name')
    expect(group.conditions_empty?).to be_truthy
    condition = create(:condition)
    cg = create(:condition_group, condition: condition, group: group)
    expect(group.conditions_empty?).to be_falsey
  end

  it "returns a hash of applicable boolean filters" do
    group = create(:group, children: true, adults: true, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = create(:group, children: false, adults: true, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).not_to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = create(:group, children: true, adults: false, healthy_volunteers: true, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).not_to eq(1)
    expect(f['healthy_volunteers']).to eq(1)

    group = create(:group, children: true, adults: true, healthy_volunteers: false, group_name: 'test name')
    f = group.apply_filters
    expect(f['children']).to eq(1)
    expect(f['adults']).to eq(1)
    expect(f['healthy_volunteers']).not_to eq(1)
  end

  context "given trial_approval is enabled" do
    it "returns accurate count of trials which reference this group" do
      create(:system_info, trial_approval: true)
      group = create(:group, group_name: 'test name')
      expect(group.study_count).to eq(0)
      condition = create(:condition)

      # Non-visible trial
      t0 = create(:trial, visible: false, approved: true)
      tc = create(:trial_condition, trial: t0, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(0)

      # Non-approved trial
      t1 = create(:trial, visible: true, approved: false)
      tc = create(:trial_condition, trial: t1, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(0)

      # First trial
      t = create(:trial, visible: true, approved: true)
      tc = create(:trial_condition, trial: t, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(1)

      # Separate but duplicated trial condition, same trial
      tc1 = create(:trial_condition, trial: t, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc1)
      expect(group.study_count).to eq(1)

      # Second trial
      t2 = create(:trial, visible: true, approved: true)
      tc2 = create(:trial_condition, trial: t2, condition: condition)
      cg2 = create(:condition_group, condition: condition, group: group, trial_condition: tc2)
      expect(group.study_count).to eq(2)
    end
  end

  context "given trial_approval is disabled" do
    it "returns accurate count of trials which reference this group" do
      create(:system_info, trial_approval: false)
      group = create(:group, group_name: 'test name')
      expect(group.study_count).to eq(0)
      condition = create(:condition)

      # Non-visible trial
      t0 = create(:trial, visible: false, approved: true)
      tc = create(:trial_condition, trial: t0, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(0)

      # Non-approved trial
      t1 = create(:trial, visible: true, approved: false)
      tc = create(:trial_condition, trial: t1, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(1)

      # Second trial
      t = create(:trial, visible: true)
      tc = create(:trial_condition, trial: t, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc)
      expect(group.study_count).to eq(2)

      # Separate but duplicated trial condition, same trial
      tc1 = create(:trial_condition, trial: t, condition: condition)
      cg = create(:condition_group, condition: condition, group: group, trial_condition: tc1)
      expect(group.study_count).to eq(2)

      # Third trial
      t2 = create(:trial, visible: true)
      tc2 = create(:trial_condition, trial: t2, condition: condition)
      cg2 = create(:condition_group, condition: condition, group: group, trial_condition: tc2)
      expect(group.study_count).to eq(3)
    end
  end

end
