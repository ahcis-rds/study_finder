require 'rails_helper'

describe Parsers::Ctgov do

  before do
  end

  describe "#parse" do

    it "parses status and sets visibility" do
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

    it "parses status and sets visibility" do
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

  end
end