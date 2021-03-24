require "rails_helper"

describe Trial do
  it "updates keywords from an array of strings" do
    trial = Trial.create
    trial.update_keywords!(["one", "two"])
    trial.reload

    expect(trial.keyword_values).to include("one")
    expect(trial.keyword_values).to include("two")
    expect(trial.keyword_values.size).to eq(2)
  end

  it "deletes keywords from an array of strings" do
    trial = Trial.create
    trial.update_keywords!(["one", "two"])
    trial.reload

    expect(trial.keyword_values).to include("one")
    expect(trial.keyword_values).to include("two")

    trial.update_keywords!(["two"])
    trial.reload

    expect(trial.keyword_values).to eq(["two"])
  end


  it "ignores keyword updates with nil" do
    trial = Trial.create
    trial.update_keywords!(["one"])
    trial.reload

    expect(trial.keyword_values).to eq(["one"])

    trial.update_keywords!(nil)
    trial.reload

    expect(trial.keyword_values).to eq(["one"])
  end

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
