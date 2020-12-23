require "rails_helper"

describe TrialIntervention do
  it ".to_s" do
    expect(TrialIntervention.new(intervention_type: "Drug").to_s).to eq("Drug")
    expect(TrialIntervention.new(intervention: "Placebo").to_s).to eq("Placebo")
    expect(TrialIntervention.new(intervention_type: "Drug", intervention: "Placebo").to_s).to eq("Drug: Placebo")
  end
end

