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

  context "when rendering simple_description" do
    context "if simple_description is non-nil and simple_description_override is nil" do
      it "returns simple_description_from_source" do
        t = build(:trial, simple_description: "Test description", simple_description_override: nil)
        expect(t.simple_description).to eq(t.simple_description_from_source)
      end
    end
    context "if simple_description is non-nil and simple_description_override is non-nil" do
      it "returns simple_description_override" do
        t = build(:trial, simple_description: "Test description", simple_description_override: "Override description")
        expect(t.simple_description).to eq(t.simple_description_override)
      end
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
    Trial.create(system_id: "123", minimum_age: nil, maximum_age: "17", visible: true, approved: true)
    Trial.create(system_id: "as7f6", minimum_age: nil, maximum_age: "18", visible: true, approved: true)
    Trial.create(system_id: "dsfg89", minimum_age: "17", maximum_age: "25", visible: true, approved: true)
    Trial.create(system_id: "jh987", minimum_age: "18", maximum_age: "30", visible: true, approved: true)
    Trial.create(system_id: "789", minimum_age: "18", maximum_age: "N/A", visible: true, approved: true)
    Trial.create(system_id: "011", minimum_age: "18", maximum_age: nil, visible: true, approved: true)
    Trial.__elasticsearch__.refresh_index!
    search_results = Trial.execute_search({"q"=> "", "children"=> ""}).results.map(&:max_age)
    expect(search_results.count).to eq(3)
    expect(search_results.sort).to eq([17.0,18.0,25.0])
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
    
  context "Given trials and subgroups bridged by TrialSubgroups" do
    it "will return correct search results with a subgroup param" do
      # Create a set of trials, a set of groups, and then two subgroups for each group. 
      # Then use Array.sample to pseudo-randomly assign 1 to 3 trials to each subgroup.
      # Like real life, this also allows for a trial to belong to more than one subgroup.
      Trial.__elasticsearch__.delete_index! 
      trials = create_list(:trial, 100)
      groups = create_list(:group, 3)
      subgroups = Array.new
      groups.map { |e| subgroups.push(*create_list(:subgroup, 2, group: e)) }

      subgroups.each_with_index do |sg, idx| 
        trials.sample([1,2,3].sample(1).first).map { |e| e.trial_subgroups.create(subgroup: sg) }
      end

      Trial.import(refresh: true, force: true)

      subgroups.each do |sg| 
        search_results = Trial.execute_search("subcat" => "#{sg.id}").results.map(&:subcategory_ids)
        expect(search_results.count).to eq(TrialSubgroup.where(subgroup: sg).count)
        # Each trial's subcategory_ids is an array of ids, so search results is an array of arrays.
        # Ensure each component array includes the subgoup id we're searching on.
        search_results.each do |r|
          expect(r).to include(sg.id)
        end
      end
    end
  end

end
