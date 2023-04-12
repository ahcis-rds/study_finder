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

  it "sorts search results by added_on date" do
    Trial.create(added_on: 5.days.ago, visible: true)
    Trial.create(added_on: 2.months.ago, visible: true)
    Trial.create(added_on: 1.day.ago, visible: true)

    result_dates = Trial.execute_search({q: ""}).results.map(&:added_on)

    expect(result_dates).to eq(result_dates.sort.reverse)
  end

  it "validates the presence of a system_id" do
    no_system_id = Trial.new(system_id: "")
    expect(no_system_id).not_to be_valid
    no_system_id.errors[:system_id].should include("can't be blank")
  end

  it "enforces uniqueness on system_id" do
    Trial.create!(system_id: "123abc")
    duplicated_system_id = Trial.new(system_id: "123abc")
    duplicated_system_id.should_not be_valid
    duplicated_system_id.errors[:system_id].should include('has already been taken')
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

  it "returns the float 0.0 when minimum_age is N/A" do 
    age_value = 'N/A'
    trial_with_age = Trial.new(minimum_age: age_value)
    expect(trial_with_age.min_age).to be(0.0) 
  end

  it "returns the float 0.0 when minimum_age is nil" do 
    age_value= nil
    trial_with_age = Trial.new(minimum_age: age_value)
    expect(trial_with_age.min_age).to be(0.0) 
  end

  it "returns the float of a value for minimum_age" do 
    age_string = '17'
    trial_with_age = Trial.new(minimum_age: age_string)
    expect(trial_with_age.min_age).to be(17.0) 
  end

  it "returns the float 1000.0 when maximum_age is N/A" do 
    age_value = 'N/A'
    trial_with_age = Trial.new(maximum_age: age_value)
    expect(trial_with_age.max_age).to be(1000.0) 
  end

  it "returns the float 0.0 when maximum_age is nil" do 
    age_value= nil
    trial_with_age = Trial.new(maximum_age: age_value)
    expect(trial_with_age.max_age).to be(1000.0) 
  end

  it "returns the float of a value for maximum_age" do 
    age_string = '72'
    trial_with_age = Trial.new(maximum_age: age_string)
    expect(trial_with_age.max_age).to be(72.0) 
  end


  it 'returns only records less than 18 for maximum age' do
    Trial.__elasticsearch__.delete_index!
    Trial.create(system_id: "123", maximum_age: "17", visible: true, approved: true)
    Trial.create(system_id: "456", maximum_age: "18", visible: true, approved: true)
    Trial.create(system_id: "789", maximum_age: "N/A", visible: true, approved: true)
    Trial.create(system_id: "011", maximum_age: nil, visible: true, approved: true)
    Trial.__elasticsearch__.refresh_index!
    search_results = Trial.execute_search({"q"=> "", "children"=> ""}).results.map(&:max_age)
    expect(search_results.count).to eq(1)
    expect(search_results).to eq([17.0])
  end

  it 'returns only records greater than or equal to 18' do
    Trial.__elasticsearch__.delete_index! 
    Trial.create(system_id: "123", maximum_age: "17", visible: true, approved: true)
    Trial.create(system_id: "456", maximum_age: "18", visible: true, approved: true)
    Trial.create(system_id: "789", maximum_age: "N/A", visible: true, approved: true)
    Trial.create(system_id: "011", maximum_age: nil, visible: true, approved: true)
    Trial.__elasticsearch__.refresh_index!
    search_results = Trial.execute_search("q"=> "", "adults"=> "1").results.map(&:max_age)
    expect(search_results.count).to eq(3)
    expect(search_results).to include(1000.0, 1000.0, 18.0)
  end
    

end
