require "rails_helper"

describe Trial do
  context "when rendering display_title" do
    it "returns nil if brief_title and acronym are both nil or empty" do
      t = build(:trial, brief_title: nil, acronym: nil)
      expect(t.display_title).to eq(nil)

      t = build(:trial, brief_title: "", acronym: nil)
      expect(t.display_title).to eq(nil)

      t = build(:trial, brief_title: nil, acronym: "")
      expect(t.display_title).to eq(nil)

      t = build(:trial, brief_title: "", acronym: "")
      expect(t.display_title).to eq(nil)
    end

    it "returns brief_title if brief_title has value and acronym is nil or empty" do
      t = build(:trial, brief_title: "Test Title", acronym: nil)
      expect(t.display_title).to eq("Test Title")

      t = build(:trial, brief_title: "Test Title", acronym: "")
      expect(t.display_title).to eq("Test Title")
    end

    it "returns concatenated brief_title and acronym in parens if both have a non-blank value" do
      t = build(:trial, brief_title: "Test Title", acronym: "TT")
      expect(t.display_title).to eq("Test Title (TT)")
    end

    it "returns nil if brief_title is nil or blank and acronym has a non-blank value " do
      t = build(:trial, brief_title: nil, acronym: "TT")
      expect(t.display_title).to eq(nil)

      t = build(:trial, brief_title: "", acronym: "TT")
      expect(t.display_title).to eq(nil)
    end

  end

  def display_title
    display = brief_title || nil
    unless acronym.nil?
      display += ' (' + acronym + ')'
    end
    display.blank? ? nil : display
  end

  it "creates associated conditions" do
    trial = create(:trial)
    trial.update_conditions!(["First Condition", "Second Condition"])
    trial.reload

    expect(trial.condition_values).to include("First Condition")
    expect(trial.condition_values).to include("Second Condition")
  end

  it "updates keywords from an array of strings" do
    trial = create(:trial)
    trial.update_keywords!(["one", "two"])
    trial.reload

    expect(trial.keyword_values).to include("one")
    expect(trial.keyword_values).to include("two")
    expect(trial.keyword_values.size).to eq(2)
  end

  it "deletes keywords from an array of strings" do
    trial = create(:trial)
    trial.update_keywords!(["one", "two"])
    trial.reload

    expect(trial.keyword_values).to include("one")
    expect(trial.keyword_values).to include("two")

    trial.update_keywords!(["two"])
    trial.reload

    expect(trial.keyword_values).to eq(["two"])
  end

  it "ignores keyword updates with nil" do
    trial = create(:trial)
    trial.update_keywords!(["one"])
    trial.reload

    expect(trial.keyword_values).to eq(["one"])

    trial.update_keywords!(nil)
    trial.reload

    expect(trial.keyword_values).to eq(["one"])
  end

  it "calculates healthy_volunteers" do
    trial = create(:trial, healthy_volunteers_imported: false, healthy_volunteers_override: nil)
    expect(trial.healthy_volunteers).to be false
  end

  it "overrides healthy_volunteers" do
    trial = create(:trial, healthy_volunteers_imported: false, healthy_volunteers_override: true)
    expect(trial.healthy_volunteers).to be true
  end

  it "detects NCT numbers" do
    expect(build(:trial, system_id: "thisisnotannctnumber").has_nct_number?).to be false
    expect(build(:trial, system_id: "NCT123").has_nct_number?).to be true
    expect(build(:trial, system_id: "nct123").has_nct_number?).to be true
  end

  it "sorts search results by added_on date" do
    create(:trial, added_on: 5.days.ago, visible: true)
    create(:trial, added_on: 2.months.ago, visible: true)
    create(:trial, added_on: 1.day.ago, visible: true)

    result_dates = Trial.execute_search({q: ""}).results.map(&:added_on)

    expect(result_dates).to eq(result_dates.sort.reverse)
  end

  it "validates the presence of a system_id" do
    no_system_id = build(:trial, system_id: "")
    expect(no_system_id).not_to be_valid
    expect(no_system_id.errors[:system_id]).to include("can't be blank")
  end

  it "enforces uniqueness on system_id" do
    create(:trial, system_id: "123abc")
    duplicated_system_id = build(:trial, system_id: "123abc")
    expect(duplicated_system_id).not_to be_valid
    expect(duplicated_system_id.errors[:system_id]).to include('has already been taken')
  end

  it "does not allow non-alphanumeric white space character to be present for system_id" do
    white_space_system_id = Trial.new(system_id: "123abc ")
    expect(white_space_system_id).not_to be_valid 
    expect(white_space_system_id.errors[:system_id]).to eq(['only allows alphanumeric characters'])
  end

  it "does not allow non-alphanumeric tab character to be present for system_id" do
    white_space_system_id = Trial.new(system_id: "123abc\t")
    expect(white_space_system_id).not_to be_valid 
    expect(white_space_system_id.errors[:system_id]).to eq(['only allows alphanumeric characters'])
  end

  it "does not allow non-alphanumeric white space comma character to be present for system_id" do
    white_space_system_id = Trial.new(system_id: "123abc, something else ")
    expect(white_space_system_id).not_to be_valid 
    expect(white_space_system_id.errors[:system_id]).to eq(['only allows alphanumeric characters'])
  end



  it 'returns only records that have an age value of "Under 18" ' do
    Trial.__elasticsearch__.delete_index!
    Trial.create(system_id: "123", age: "18 or older", visible: true, approved: true)
    Trial.create(system_id: "456", age: "All ages", visible: true, approved: true)
    Trial.create(system_id: "789", age: "Under 18", visible: true, approved: true)
    Trial.create(system_id: "011", visible: true, approved: true)
    Trial.__elasticsearch__.refresh_index!
    search_results = Trial.execute_search({"q"=> "", "children"=> ""}).results.map(&:age)
    expect(search_results.count).to eq(1)
  end

  it 'returns only records that have an age value of "18 or older"' do
    Trial.__elasticsearch__.delete_index! 
    Trial.create(system_id: "123", age: "Under 18", visible: true, approved: true)
    Trial.create(system_id: "456", age: "All ages", visible: true, approved: true)
    Trial.create(system_id: "789", age: "18 or older", visible: true, approved: true)
    Trial.create(system_id: "011",age: "18 or older", visible: true, approved: true)
    Trial.__elasticsearch__.refresh_index!
    search_results = Trial.execute_search("q"=> "", "adults"=> "1").results.map(&:age)
    expect(search_results.count).to eq(2)
  end
    

end
