require "rails_helper"

describe Trial do
  it "updates keywords from an array of string" do
    trial = Trial.create
    trial.update_keywords!(["one", "two"])
    trial.reload

    expect(trial.keyword_values).to include("one")
    expect(trial.keyword_values).to include("two")
    expect(trial.keyword_values.size).to eq(2)
  end
end
