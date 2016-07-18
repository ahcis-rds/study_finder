require 'rails_helper'

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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(true)

      p2 = Parsers::Ctgov.new( 'NCT01678638', 1)
      p2.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Not yet Recruiting</overall_status>
        </clinical_study>
      ")
      p2.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
      expect(trial.visible).to eq(false)

      p2 = Parsers::Ctgov.new( 'NCT01678638', 1)
      p2.set_contents_from_xml("
        <clinical_study>
          <brief_title>Test Study</brief_title>
          <overall_status>Recruiting</overall_status>
        </clinical_study>
      ")
      p2.process(true)

      trial2 = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
      expect(trial2.visible).to eq(true)
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
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
      p.process(true)

      trial = StudyFinder::Trial.find_by(system_id: 'NCT01678638')
      expect(trial.conditions.size).to eq(4)
      expect(trial.conditions.first.condition).to eq('Test Condition 1')
      expect(trial.conditions.last.condition).to eq('Test Condition 4')
    end

  end
end