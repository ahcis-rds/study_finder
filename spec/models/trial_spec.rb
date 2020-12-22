require "rails_helper"

describe Trial do
  it "handles nil intervention types" do
    trial = Trial.new
    trial.trial_interventions.build(intervention: "Blah")

    expect(trial.interventions).to eq("Blah")
  end
end
