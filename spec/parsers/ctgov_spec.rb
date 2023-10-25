require 'rails_helper'
require 'parsers/ctgov'

describe Parsers::Ctgov do

  before do
  end

  describe "#parse" do

    it "parses status and sets visibility when Recruiting" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Recruiting</overall_status>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(true)
    end

    it "parses status and sets visibility when not Recruiting" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Not yet Recruiting</overall_status>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(false)
    end 

    it "parses status and sets visibility from Recruiting to not Recruiting" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Recruiting</overall_status>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(true)

      p2 = Parsers::Ctgov.new( 'NCT01678638', 1)
      p2.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Not yet Recruiting</overall_status>
        </clinical_study>
      ")
      p2.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(false)
    end

    it "parses status and sets visibility from not Recruiting to Recruiting" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Not yet Recruiting</overall_status>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(false)

      p2 = Parsers::Ctgov.new( 'NCT01678638', 1)
      p2.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Recruiting</overall_status>
        </clinical_study>
      ")
      p2.process

      trial2 = Trial.find_by(system_id: 'NCT01678638')
      expect(trial2.visible).to eq(true)
    end

   it "sets visibility correctly regardless of current value" do
      trial = create(:trial, system_id: "NCT123", overall_status: "Completed", visible: true)
      p = Parsers::Ctgov.new("NCT123", 1)

      p.set_contents_from_xml("
        <clinical_study>
          <overall_status>Completed</overall_status>
        </clinical_study>
      ")

      p.process
      trial.reload

      expect(trial.visible).to eq(false)
    end

    it "parses age ranges correctly when weeks are involved" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <eligibility>
            <criteria>
              <textblock></textblock>
            </criteria>
            <gender>Both</gender>
            <minimum_age>N/A</minimum_age>
            <maximum_age>37 Weeks</maximum_age>
            <healthy_volunteers>No</healthy_volunteers>
          </eligibility>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.minimum_age).to eq(nil)
      expect(trial.maximum_age).to eq('0.71')
    end

    it "parses age ranges correctly when years are involved" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <eligibility>
            <criteria>
              <textblock></textblock>
            </criteria>
            <gender>Both</gender>
            <minimum_age>37 Days</minimum_age>
            <maximum_age>2 Years</maximum_age>
            <healthy_volunteers>No</healthy_volunteers>
          </eligibility>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.minimum_age).to eq('0.1')
      expect(trial.min_age_unit).to eq('37 Days')
      expect(trial.maximum_age).to eq('2')
      expect(trial.max_age_unit).to eq('2 Years')
    end

    it "parses age ranges correctly when months are involved" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <eligibility>
            <criteria>
              <textblock></textblock>
            </criteria>
            <gender>Both</gender>
            <minimum_age>13 Months</minimum_age>
            <maximum_age>300 Months</maximum_age>
            <healthy_volunteers>No</healthy_volunteers>
          </eligibility>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.minimum_age).to eq('1.08')
      expect(trial.min_age_unit).to eq('13 Months')
      expect(trial.maximum_age).to eq('25.0')
      expect(trial.max_age_unit).to eq('300 Months')
    end

    it "parses conditions when there is only one" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <eligibility>
            <criteria>
              <textblock></textblock>
            </criteria>
            <gender>Both</gender>
            <minimum_age>13 Months</minimum_age>
            <maximum_age>300 Months</maximum_age>
            <healthy_volunteers>No</healthy_volunteers>
          </eligibility>
          <condition>Test Condition</condition>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.conditions.first.condition).to eq('Test Condition')
    end

    it "parses conditions when there are many" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <eligibility>
            <criteria>
              <textblock></textblock>
            </criteria>
            <gender>Both</gender>
            <minimum_age>13 Months</minimum_age>
            <maximum_age>300 Months</maximum_age>
            <healthy_volunteers>No</healthy_volunteers>
          </eligibility>
          <condition>Test Condition 1</condition>
          <condition>Test Condition 2</condition>
          <condition>Test Condition 3</condition>
          <condition>Test Condition 4</condition>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.conditions.size).to eq(4)
      expect(trial.conditions.first.condition).to eq('Test Condition 1')
      expect(trial.conditions.last.condition).to eq('Test Condition 4')
    end

    it "parses intervention when there is only one" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <intervention>
            <intervention_type>Intervention Type</intervention_type>
            <intervention_name>Intervention Name</intervention_name>
          </intervention>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.interventions).to eq('Intervention Type: Intervention Name')
    end

    it "parses intervention when there are many" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <intervention>
            <intervention_type>Intervention Type 1</intervention_type>
            <intervention_name>Intervention Name 1</intervention_name>
          </intervention>
          <intervention>
            <intervention_type>Intervention Type 2</intervention_type>
            <intervention_name>Intervention Name 2</intervention_name>
          </intervention>
          <intervention>
            <intervention_type>Intervention Type 3</intervention_type>
            <intervention_name>Intervention Name 3</intervention_name>
          </intervention>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      interventions = trial.interventions.split("; ")
      expect(interventions.size).to eq(3)
      expect(interventions.first).to eq('Intervention Type 1: Intervention Name 1')
      expect(interventions.second).to eq('Intervention Type 2: Intervention Name 2')
      expect(interventions.third).to eq('Intervention Type 3: Intervention Name 3')
    end

    it "parses keyword when there is only one" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <keyword>Test Keyword</keyword>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.keywords).to eq("Test Keyword")
    end

    it "parses keyword when there are many" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <keyword>Test Keyword 1</keyword>
          <keyword>Test Keyword 2</keyword>
          <keyword>Test Keyword 3</keyword>
          <keyword>Test Keyword 4</keyword>
          <keyword>Test Keyword 5</keyword>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      keywords = trial.keywords.split("; ")
      expect(keywords.size).to eq(5)
      expect(keywords.first).to eq("Test Keyword 1")
      expect(keywords.second).to eq("Test Keyword 2")
      expect(keywords.last).to eq("Test Keyword 5")
    end

    it "parses conditional browse mesh term when there is one" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <conditional_browse>
            <mesh_term>Test Conditional Mesh Term</mesh_term>
          </conditional_browse>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.mesh_terms).to eq("Conditional: Test Conditional Mesh Term")
    end

    it "parses conditional browse mesh term when there are many" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <conditional_browse>
            <mesh_term>Test Conditional Mesh Term 1</mesh_term>
            <mesh_term>Test Conditional Mesh Term 2</mesh_term>
            <mesh_term>Test Conditional Mesh Term 3</mesh_term>
          </conditional_browse>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(3)
      expect(mesh_term.first).to eq("Conditional: Test Conditional Mesh Term 1")
      expect(mesh_term.second).to eq("Conditional: Test Conditional Mesh Term 2")
      expect(mesh_term.last).to eq("Conditional: Test Conditional Mesh Term 3")
    end

    it "parses intervention browse mesh term when there is one" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <intervention_browse>
            <mesh_term>Test Intervention Mesh Term</mesh_term>
          </intervention_browse>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      expect(trial.mesh_terms).to eq("Intervention: Test Intervention Mesh Term")
    end

    it "parses intervention browse mesh term when there are many" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <intervention_browse>
            <mesh_term>Test Intervention Mesh Term 1</mesh_term>
            <mesh_term>Test Intervention Mesh Term 2</mesh_term>
            <mesh_term>Test Intervention Mesh Term 3</mesh_term>
          </intervention_browse>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(3)
      expect(mesh_term.first).to eq("Intervention: Test Intervention Mesh Term 1")
      expect(mesh_term.second).to eq("Intervention: Test Intervention Mesh Term 2")
      expect(mesh_term.last).to eq("Intervention: Test Intervention Mesh Term 3")
    end


    it "parses conditional and intervention browse mesh term" do
      url = 'https://clinicaltrials.gov/show/NCT01678638?displayxml=true'
      p = Parsers::Ctgov.new( 'NCT01678638', 1)
      p.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <conditional_browse>
            <mesh_term>Test Conditional Mesh Term 1</mesh_term>
            <mesh_term>Test Conditional Mesh Term 2</mesh_term>
            <mesh_term>Test Conditional Mesh Term 3</mesh_term>
          </conditional_browse>
          <intervention_browse>
            <mesh_term>Test Intervention Mesh Term 1</mesh_term>
            <mesh_term>Test Intervention Mesh Term 2</mesh_term>
            <mesh_term>Test Intervention Mesh Term 3</mesh_term>
          </intervention_browse>
        </clinical_study>
      ")
      p.process

      trial = Trial.find_by(system_id: 'NCT01678638')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(6)
      expect(mesh_term.first).to eq("Conditional: Test Conditional Mesh Term 1")
      expect(mesh_term.second).to eq("Conditional: Test Conditional Mesh Term 2")
      expect(mesh_term.third).to eq("Conditional: Test Conditional Mesh Term 3")
      expect(mesh_term.fourth).to eq("Intervention: Test Intervention Mesh Term 1")
      expect(mesh_term.fifth).to eq("Intervention: Test Intervention Mesh Term 2")
      expect(mesh_term.last).to eq("Intervention: Test Intervention Mesh Term 3")
    end
  end

  it "#overall_status" do
    p = Parsers::Ctgov.new("NCT123")
    p.set_contents_from_xml("
      <clinical_study>
        <overall_status>Recruiting</overall_status>
      </clinical_study>
    ")

    expect(p.overall_status).to eq("Recruiting")
  end

  it "#location_status with one location" do
    p = Parsers::Ctgov.new("NCT123")
    p.set_contents_from_xml("
      <clinical_study>
        <location>
          <facility>
            <name>University of Minnesota</name>
          </facility>
          <status>Some status</status>
        </location>
      </clinical_study>
    ")
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.location_status).to eq("Some status")
  end

  it "#location_status with multiple locations" do
    p = Parsers::Ctgov.new("NCT123")
    p.set_contents_from_xml("
      <clinical_study>
        <location>
          <facility>
            <name>Somewhere else</name>
          </facility>
          <status>Another status</status>
        </location>
        <location>
          <facility>
            <name>University of Minnesota</name>
          </facility>
          <status>Some status</status>
        </location>
      </clinical_study>
    ")
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.location_status).to eq("Some status")
  end

  it "#calculated_status" do
    p = Parsers::Ctgov.new("NCT123")
    p.set_contents_from_xml("
      <clinical_study>
        <overall_status>Not this one</overall_status>
        <location>
          <facility>
            <name>University of Minnesota</name>
          </facility>
          <status>This one</status>
        </location>
      </clinical_study>
    ")
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.calculated_status).to eq("This one")
  end

  it "#calculated_status with no location status" do
    p = Parsers::Ctgov.new("NCT123")
    p.set_contents_from_xml("
      <clinical_study>
        <overall_status>Some status</overall_status>
        <location>
          <facility>
            <name>University of Minnesota</name>
          </facility>
        </location>
      </clinical_study>
    ")
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.calculated_status).to eq("Some status")
  end
end
