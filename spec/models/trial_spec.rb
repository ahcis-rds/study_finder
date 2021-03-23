require "rails_helper"

describe Trial do
  it "calculates healthy_volunteers" do
    trial = Trial.create(healthy_volunteers_imported: false)
    expect(trial.healthy_volunteers).to be false
  end

  it "overrides healthy_volunteers" do
    trial = Trial.create(healthy_volunteers_imported: false)
    trial.update(healthy_volunteers_override: true)
    expect(trial.healthy_volunteers).to be true
  end

  it "detects NCT numbers" do
    expect(Trial.new(system_id: "thisisnotannctnumber").has_nct_number?).to be false
    expect(Trial.new(system_id: "NCT123").has_nct_number?).to be true
    expect(Trial.new(system_id: "nct123").has_nct_number?).to be true
  end
end
