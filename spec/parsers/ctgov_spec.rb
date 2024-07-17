require 'rails_helper'
require 'parsers/ctgov'

describe Parsers::Ctgov do

  before(:each) do
    system_info = create(:system_info, initials: 'TSTU', search_term: "Test University") 
    @api_data = {
      "protocolSection" => {
        "identificationModule" => {
          "nctId" => "NCT999999",
          "orgStudyIdInfo" => {
            "id" => "2024-STUDY"
          },
          "organization" => {
            "fullName" => "Spacely Sprockets", "class" => "INDUSTRY"
          },
          "briefTitle" => 
           "This is the brief title",
          "officialTitle" => 
           "This is the longer, official title",
          "acronym" => "ACRO"
        },
        "statusModule" => {
          "statusVerifiedDate" => "2024-06",
          "overallStatus" => "RECRUITING",
          "expandedAccessInfo" => {"hasExpandedAccess" => false},
          "startDateStruct" => {"date" => "2023-10-30", "type" => "ACTUAL"},
          "primaryCompletionDateStruct" => {"date" => "2027-11", "type" => "ESTIMATED"},
          "completionDateStruct" => {"date" => "2027-11", "type" => "ESTIMATED"},
          "studyFirstSubmitDate" => "2023-07-05",
          "studyFirstSubmitQcDate" => "2023-07-05",
          "studyFirstPostDateStruct" => {"date" => "2023-07-13", "type" => "ACTUAL"},
          "lastUpdateSubmitDate" => "2024-06-28",
          "lastUpdatePostDateStruct" => {"date" => "2024-07-01", "type" => "ACTUAL"}
        },
        "sponsorCollaboratorsModule" => {
          "responsibleParty" => {"type" => "SPONSOR"}, "leadSponsor" => {"name" => "Spacely Sprockets", "class" => "INDUSTRY"}
        },
        "oversightModule" => {
          "oversightHasDmc" => true, "isFdaRegulatedDrug" => true, "isFdaRegulatedDevice" => true
        },
        "descriptionModule" => {
          "briefSummary" => 
           "This summary of the study is brief.",
          "detailedDescription" => 
           "This detailed description of the study is longer. This detailed description of the study is longer. This detailed description of the study is longer. This detailed description of the study is longer."
        },
        "conditionsModule" => {
          "conditions" => ["Condition 1", "Condition 2"],
          "keywords" => ["Test Keyword 1", "Test Keyword 2", "Test Keyword 3"]
        },
        "designModule" => {
          "studyType" => "INTERVENTIONAL",
          "phases" => ["PHASE3"],
          "designInfo" => {
            "allocation" => "RANDOMIZED",
            "interventionModel" => "PARALLEL",
            "primaryPurpose" => "TREATMENT",
            "maskingInfo" => 
             {"masking" => "QUADRUPLE", "whoMasked" => ["PARTICIPANT", "CARE_PROVIDER", "INVESTIGATOR", "OUTCOMES_ASSESSOR"]}
          },
          "enrollmentInfo" => {"count" => 200, "type" => "ESTIMATED"}
        },
        "armsInterventionsModule" => {
          "armGroups" => 
           [{"label" => "Placebo",
             "type" => "PLACEBO_COMPARATOR",
             "description" => "A placebo arm.",
             "interventionNames" => ["Drug: Placebo", "Device: Some Device"]},
            {"label" => "Real Drug Label",
             "type" => "EXPERIMENTAL",
             "description" => 
              "Drug arm description",
             "interventionNames" => ["Drug: Real Drug", "Device: Some Device"]}],
          "interventions" => 
           [{"type" => "DRUG", "name" => "Placebo", "description" => "Placebo intervention description", "armGroupLabels" => ["Placebo"]},
            {"type" => "DRUG",
             "name" => "Real Drug",
             "description" => "Drug intervention description",
             "armGroupLabels" => ["Real Drug Label"],
             "otherNames" => ["Drug Brand Name", "Drug Brand Name 2"]},
            {"type" => "DEVICE",
             "name" => "Some Device",
             "description" => "Device intervention description",
             "armGroupLabels" => ["Real Drug Label", "Placebo"]}]
        },
        "outcomesModule" => {
          "primaryOutcomes" => 
           [{"measure" => "Measure 1",
             "description" => 
              "Measure 1 description.",
             "timeFrame" => "Baseline to Week 52"}],
          "secondaryOutcomes" => 
           [{"measure" => "Measure 2",
             "description" => 
              "Measure 2 description.",
             "timeFrame" => "Baseline to Week 52"},
            {"measure" => "Measure 3",
             "description" => 
              "Measure 3 description.",
             "timeFrame" => "Baseline to Week 52"}]
        },
        "eligibilityModule" => {
          "eligibilityCriteria" => "These are eligibility criteria.",
          "healthyVolunteers" => false,
          "sex" => "ALL",
          "minimumAge" => "18 Years",
          "stdAges" => ["ADULT", "OLDER_ADULT"]
        },
        "contactsLocationsModule" => {
          "centralContacts" => 
           [{"name" => "Spacely Sprockets Contact",
             "role" => "CONTACT",
             "phone" => "555-555-5555",
             "email" => "clinicaltrials@spacelysprockets.com"}],
          "overallOfficials"=>
            [{"name"=>"Person One, PhD", 
              "affiliation"=>"The Major Medical Center", 
              "role"=>"PRINCIPAL_INVESTIGATOR"}],
          "locations" => 
           [
            {"facility" => "Facility 1 Name",
             "status" => "RECRUITING",
             "city" => "Chicago",
             "state" => "Illinois",
             "zip" => "60193",
             "country" => "United States",
             "contacts" => 
              [{"name" => "Facility 1 Contact 1 Name", "role" => "CONTACT", "phone" => "555-555-5556", "email" => "someone@facility1.zzz"},
               {"name" => "Facility 1 Contact 2 Name", "role" => "PRINCIPAL_INVESTIGATOR"}],
             "geoPoint" => {"lat" => 33.52066, "lon" => -86.80249}},
            {"facility" => "Facility 2 Name",
             "status" => "RECRUITING",
             "city" => "Phoenix",
             "state" => "Arizona",
             "zip" => "85013",
             "country" => "United States",
             "contacts" => 
              [{"name" => "Facility 2 Contact 1 Name",
                "role" => "CONTACT",
                "phone" => "602-555-5555",
                "email" => "someone@facility2.zzz"},
               {"name" => "Facility 2 Contact 2 Name", "role" => "PRINCIPAL_INVESTIGATOR"}],
             "geoPoint" => {"lat" => 33.44838, "lon" => -112.07404}}
           ]
        }
      },
      "derivedSection" => {
        "miscInfoModule" => {"versionHolder" => "2024-07-12"},
        "conditionBrowseModule" => {
          "meshes" => 
           [{"id" => "D000008171", "term" => "Lung Diseases"},
            {"id" => "D000011658", "term" => "Pulmonary Fibrosis"},
            {"id" => "D000017563", "term" => "Lung Diseases, Interstitial"},
            {"id" => "D000005355", "term" => "Fibrosis"}],
          "ancestors" => 
           [{"id" => "D000010335", "term" => "Pathologic Processes"}, {"id" => "D000012140", "term" => "Respiratory Tract Diseases"}],
          "browseLeaves" => 
           [{"id" => "M11168", "name" => "Lung Diseases", "asFound" => "Lung Disease", "relevance" => "HIGH"},
            {"id" => "M27137", "name" => "Respiratory Aspiration", "relevance" => "LOW"},
            {"id" => "M19813", "name" => "Lung Diseases, Interstitial", "asFound" => "Interstitial Lung Disease", "relevance" => "HIGH"},
            {"id" => "M8485", "name" => "Fibrosis", "asFound" => "Fibrosis", "relevance" => "HIGH"},
            {"id" => "M14512", "name" => "Pulmonary Fibrosis", "asFound" => "Pulmonary Fibrosis", "relevance" => "HIGH"},
            {"id" => "M14977", "name" => "Respiratory Tract Diseases", "relevance" => "LOW"}],
          "browseBranches" => 
           [{"abbrev" => "BC08", "name" => "Respiratory Tract (Lung and Bronchial) Diseases"},
            {"abbrev" => "All", "name" => "All Conditions"},
            {"abbrev" => "BC23", "name" => "Symptoms and General Pathology"}]
        },
        "interventionBrowseModule" => {
          "meshes" => [{"id" => "C000427248", "term" => "Treprostinil"}],
          "ancestors" => [{"id" => "D000000959", "term" => "Antihypertensive Agents"}],
          "browseLeaves" => 
           [{"id" => "M21860", "name" => "Pharmaceutical Solutions", "relevance" => "LOW"},
            {"id" => "M255601", "name" => "Treprostinil", "asFound" => "Operator", "relevance" => "HIGH"},
            {"id" => "M4277", "name" => "Antihypertensive Agents", "relevance" => "LOW"}],
          "browseBranches" => 
           [{"abbrev" => "PhSol", "name" => "Pharmaceutical Solutions"},
            {"abbrev" => "All", "name" => "All Drugs and Chemicals"},
            {"abbrev" => "AnAg", "name" => "Antihypertensive Agents"}]
        }
      }
    }
  end

  describe "#contents" do
    it "returns a structure equivalent to @api_data" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      expect(p.contents).to eq(@api_data)
    end
  end

  describe "#location_search_term" do
    it "returns the correct term" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      expect(p.location_search_term).to eq("Test University")
    end
  end

  describe "#location" do
    it "returns the correct location block for an exact match" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      allow(p).to receive(:location_search_term) { "Facility 1 Name" }
      expect(p.location["facility"]).to eq("Facility 1 Name")
      expect(p.location["city"]).to eq("Chicago")
      expect(p.location["state"]).to eq("Illinois")
    end

    it "returns the correct location block for a substring match" do
      @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
          {"facility"=>"University of Minnesota/Cancer Center","status"=>"Some status","city"=>"Minneapolis",
           "state"=>"Minnesota","zip"=>"55455","country"=>"United States"
          }
        ]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)

      allow(p).to receive(:location_search_term) { "University of Minnesota" }
      expect(p.location["facility"]).to eq("University of Minnesota/Cancer Center")
      expect(p.location["city"]).to eq("Minneapolis")
      expect(p.location["state"]).to eq("Minnesota")
    end
  end

  describe "#preview" do
    it "returns the correct preview block" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      expect(p.preview.system_id).to eq("NCT999999")
      expect(p.preview.brief_title).to eq("This is the brief title")
      expect(p.preview.official_title).to eq("This is the longer, official title")
      expect(p.preview.acronym).to eq("ACRO")
      expect(p.preview.phase).to eq("PHASE3")
      expect(p.preview.overall_status).to eq("RECRUITING")
      expect(p.preview.verification_date).to eq("2024-06")
      expect(p.preview.brief_summary).to eq("This summary of the study is brief.")
      expect(p.preview.detailed_description).to eq("This detailed description of the study is longer. This detailed description of the study is longer. This detailed description of the study is longer. This detailed description of the study is longer.")
      expect(p.preview.visible).to eq(true)
      expect(p.preview.lastchanged_date).to eq('2024-06-28')
      expect(p.preview.firstreceived_date).to eq('2023-07-05')
      expect(p.preview.min_age_unit).to eq(nil)
      expect(p.preview.maximum_age).to eq(nil)
    end
  end

  describe "#process_contacts" do
    context "if there is one location contact with an email, and one central contact" do
      it "returns those in order as the primary and backup" do
        p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
        allow(p).to receive(:location_search_term) { "Facility 1 Name" }
        t = Trial.new
        p.process_contacts(t)
        expect(t.contact_last_name).to eq('Facility 1 Contact 1 Name')
        expect(t.contact_backup_last_name).to eq('Spacely Sprockets Contact')
      end
    end
    context "if there are two location contacts with an email" do
      it "returns those in order as the primary and backup" do
        @api_data["protocolSection"]["contactsLocationsModule"]["locations"][0]["contacts"][1]["email"] = "someone2@facility1.zzz"
        p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
        allow(p).to receive(:location_search_term) { "Facility 1 Name" }
        t = Trial.new
        p.process_contacts(t)
        expect(t.contact_last_name).to eq('Facility 1 Contact 1 Name')
        expect(t.contact_backup_last_name).to eq('Facility 1 Contact 2 Name')
      end
    end
  end

  describe "#process_eligibility" do
    it "parses sex correctly" do
      @api_data["protocolSection"]["eligibilityModule"]["sex"] = "ALL"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.gender).to eq("ALL")
    end

    it "parses age ranges correctly when weeks are involved" do
      @api_data["protocolSection"]["eligibilityModule"]["minimumAge"] = nil
      @api_data["protocolSection"]["eligibilityModule"]["maximumAge"] = "37 Weeks"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.minimum_age).to eq(nil)
      expect(t.maximum_age).to eq('0.71')
    end

    it "parses age ranges correctly when years are involved" do
      @api_data["protocolSection"]["eligibilityModule"]["minimumAge"] = "37 Days"
      @api_data["protocolSection"]["eligibilityModule"]["maximumAge"] = "2 Years"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.minimum_age).to eq('0.1')
      expect(t.min_age_unit).to eq('37 Days')
      expect(t.maximum_age).to eq('2')
      expect(t.max_age_unit).to eq('2 Years')
    end

    it "parses age ranges correctly when months are involved" do
      @api_data["protocolSection"]["eligibilityModule"]["minimumAge"] = "13 Months"
      @api_data["protocolSection"]["eligibilityModule"]["maximumAge"] = "300 Months"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.minimum_age).to eq('1.08')
      expect(t.min_age_unit).to eq('13 Months')
      expect(t.maximum_age).to eq('25.0')
      expect(t.max_age_unit).to eq('300 Months')
    end

    it "parses healthy volunteers correctly" do
      @api_data["protocolSection"]["eligibilityModule"]["healthyVolunteers"] = true
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.healthy_volunteers_imported).to eq(true)

      @api_data["protocolSection"]["eligibilityModule"]["healthyVolunteers"] = false
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.healthy_volunteers_imported).to eq(false)
    end

    it "parses eligibilityCriteria correctly" do
      @api_data["protocolSection"]["eligibilityModule"]["eligibilityCriteria"] = "Test Criteria 1 through 10."
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      t = Trial.new
      p.process_eligibility(t)
      expect(t.eligibility_criteria).to eq("Test Criteria 1 through 10.")
    end
  end

  describe "#process_locations" do
    context "when there is a location present with one contact" do
      it "creates a location record and a trial location with one contact" do
        @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
          {"facility"=>"University of Minnesota","status"=>"Some status","city"=>"Minneapolis",
           "state"=>"Minnesota","zip"=>"55455","country"=>"United States",
           "contacts" => 
              [{"name" => "UMN Contact 1 Name", "role" => "CONTACT", "phone" => "555-555-5556", "email" => "someone@umn.edu"},
               {"name" => "UMN Contact 2 Name", "role" => "PRINCIPAL_INVESTIGATOR"}]
          }
        ]
        p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
        t = create(:trial)
        p.process_locations(t.id)
        tl = TrialLocation.first
        l = tl.location
        expect(l.location).to eq("University of Minnesota")
        expect(l.city).to eq("Minneapolis")
        expect(l.state).to eq("Minnesota")
        expect(l.zip).to eq("55455")
        expect(l.country).to eq("United States")

        expect(tl.status).to eq("Some status")
        expect(tl.last_name).to eq("UMN Contact 1 Name")
        expect(tl.phone).to eq("555-555-5556")
        expect(tl.email).to eq("someone@umn.edu")
        expect(tl.backup_last_name).to eq(nil)
        expect(tl.backup_phone).to eq(nil)
        expect(tl.backup_email).to eq(nil)
      end
      it "creates a location record and a trial location with one contact" do
        @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
          {"facility"=>"University of Minnesota","status"=>"Some status","city"=>"Minneapolis",
           "state"=>"Minnesota","zip"=>"55455","country"=>"United States",
           "contacts" => 
              [{"name" => "UMN Contact 1 Name", "role" => "CONTACT", "phone" => "555-555-5556", "email" => "someone@umn.edu"},
               {"name" => "UMN Contact 2 Name", "role" => "CONTACT", "phone" => "555-555-5557", "email" => "another@umn.edu"},
               {"name" => "UMN Contact 3 Name", "role" => "PRINCIPAL_INVESTIGATOR"}]
          }
        ]
        p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
        t = create(:trial)
        p.process_locations(t.id)
        tl = TrialLocation.first
        l = tl.location
        expect(l.location).to eq("University of Minnesota")
        expect(l.city).to eq("Minneapolis")
        expect(l.state).to eq("Minnesota")
        expect(l.zip).to eq("55455")
        expect(l.country).to eq("United States")

        expect(tl.status).to eq("Some status")
        expect(tl.last_name).to eq("UMN Contact 1 Name")
        expect(tl.phone).to eq("555-555-5556")
        expect(tl.email).to eq("someone@umn.edu")
        expect(tl.backup_last_name).to eq("UMN Contact 2 Name")
        expect(tl.backup_phone).to eq("555-555-5557")
        expect(tl.backup_email).to eq("another@umn.edu")
      end
    end
  end

  describe "#parse" do
    it "parses status and sets visibility when Recruiting" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.visible).to eq(true)
    end

    it "parses status and sets visibility when not Recruiting" do
      @api_data["protocolSection"]["statusModule"]["overallStatus"] = "Not yet recruiting"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.visible).to eq(false)
    end 

    it "parses status change from recruiting to non and sets visibility from true to false" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.visible).to eq(true)

      @api_data["protocolSection"]["statusModule"]["overallStatus"] = "Not yet recruiting"
      p2 = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p2.process

      trial.reload
      expect(trial.visible).to eq(false)
    end

    it "parses status and sets visibility from false to true" do
      @api_data["protocolSection"]["statusModule"]["overallStatus"] = "Not yet recruiting"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.visible).to eq(false)

      @api_data["protocolSection"]["statusModule"]["overallStatus"] = "RECRUITING"
      p2 = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p2.process

      trial.reload
      expect(trial.visible).to eq(true)
    end

    it "sets visibility correctly regardless of current value" do
      trial = create(:trial, system_id: "NCT999999", overall_status: "Completed", visible: true)
      expect(trial.visible).to eq(true)

      @api_data["protocolSection"]["statusModule"]["overallStatus"] = "COMPLETED"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process
      trial.reload

      expect(trial.visible).to eq(false)
    end

    it "parses conditions when there is only one" do
      @api_data["protocolSection"]["conditionsModule"]["conditions"] = "Test Condition"
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.conditions.first.condition).to eq('Test Condition')
    end

    it "parses conditions when there are many" do
      @api_data["protocolSection"]["conditionsModule"]["conditions"] = ["Test Condition 1", "Test Condition 3", "Test Condition 3", "Test Condition 4"]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.conditions.size).to eq(4)
      expect(trial.conditions.first.condition).to eq('Test Condition 1')
      expect(trial.conditions.last.condition).to eq('Test Condition 4')
    end

    it "parses intervention when there is only one" do
      @api_data["protocolSection"]["armsInterventionsModule"]["interventions"] = [
        {"type" => "DRUG",
         "name" => "Real Drug",
         "description" => "Drug intervention description",
         "armGroupLabels" => ["Real Drug Label"],
         "otherNames" => ["Drug Brand Name", "Drug Brand Name 2"]
        }
      ]

      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.interventions).to eq('DRUG: Real Drug')
    end

    it "parses interventions when there are many" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      interventions = trial.interventions.split("; ")
      expect(interventions.size).to eq(3)
      expect(interventions.first).to eq('DRUG: Placebo')
      expect(interventions.second).to eq('DRUG: Real Drug')
      expect(interventions.third).to eq('DEVICE: Some Device')
    end

    it "parses keyword when there is only one" do
      @api_data["protocolSection"]["conditionsModule"]["keywords"] = ["Test Keyword"]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.keywords).to eq("Test Keyword")
    end

    it "parses keyword when there are many" do
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      keywords = trial.keywords.split("; ")
      expect(keywords.size).to eq(3)
      expect(keywords.first).to eq("Test Keyword 1")
      expect(keywords.second).to eq("Test Keyword 2")
      expect(keywords.last).to eq("Test Keyword 3")
    end

    it "parses conditional browse mesh term when there is one" do
      @api_data["derivedSection"]["conditionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Conditional Mesh Term"}]
      @api_data["derivedSection"]["interventionBrowseModule"]["meshes"] = []
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.mesh_terms).to eq("Conditional: Test Conditional Mesh Term")
    end

    it "parses conditional browse mesh term when there are many" do
      @api_data["derivedSection"]["conditionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Conditional Mesh Term 1"},{"id"=>"D002","term"=>"Test Conditional Mesh Term 2"}]
      @api_data["derivedSection"]["interventionBrowseModule"]["meshes"] = []
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(2)
      expect(mesh_term.first).to eq("Conditional: Test Conditional Mesh Term 1")
      expect(mesh_term.last).to eq("Conditional: Test Conditional Mesh Term 2")
    end

    it "parses intervention browse mesh term when there is one" do
      @api_data["derivedSection"]["conditionBrowseModule"]["meshes"] = []
      @api_data["derivedSection"]["interventionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Intervention Mesh Term"}]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      expect(trial.mesh_terms).to eq("Intervention: Test Intervention Mesh Term")
    end

    it "parses intervention browse mesh term when there are many" do
      @api_data["derivedSection"]["conditionBrowseModule"]["meshes"] = []
      @api_data["derivedSection"]["interventionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Intervention Mesh Term 1"},{"id"=>"D002","term"=>"Test Intervention Mesh Term 2"}]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(2)
      expect(mesh_term.first).to eq("Intervention: Test Intervention Mesh Term 1")
      expect(mesh_term.last).to eq("Intervention: Test Intervention Mesh Term 2")
    end

    it "parses conditional and intervention browse mesh term" do
      @api_data["derivedSection"]["conditionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Conditional Mesh Term 1"},{"id"=>"D002","term"=>"Test Conditional Mesh Term 2"}]
      @api_data["derivedSection"]["interventionBrowseModule"]["meshes"] = [{"id"=>"D001","term"=>"Test Intervention Mesh Term 1"}]
      p = Parsers::Ctgov.new( 'NCT999999', 1, @api_data)
      p.process

      trial = Trial.find_by(system_id: 'NCT999999')
      mesh_term = trial.mesh_terms.split("; ")
      expect(mesh_term.size).to eq(3)
      expect(mesh_term.first).to eq("Conditional: Test Conditional Mesh Term 1")
      expect(mesh_term.second).to eq("Conditional: Test Conditional Mesh Term 2")
      expect(mesh_term.third).to eq("Intervention: Test Intervention Mesh Term 1")
    end
  end

  it "#overall_status" do
    @api_data["protocolSection"]["statusModule"]["overallStatus"] = "RECRUITING"
    p = Parsers::Ctgov.new("NCT123", 1, @api_data)
    expect(p.overall_status).to eq("RECRUITING")
  end

  it "#location_status with one location" do
    @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [{"facility"=>"University of Minnesota","status"=>"Some status"}]
    p = Parsers::Ctgov.new("NCT123", 1, @api_data)
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.location_status).to eq("Some status")
  end

  it "#location_status with multiple locations" do
    @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
      {"facility"=>"University of Minnesota","status"=>"Some status"},
      {"facility"=>"University of Wisconsin","status"=>"A different status"},
    ]
    p = Parsers::Ctgov.new("NCT123", 1, @api_data)
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.location_status).to eq("Some status")
  end

  it "#calculated_status" do
    @api_data["protocolSection"]["statusModule"]["overallStatus"] = "RECRUITING"
    @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
      {"facility"=>"University of Minnesota","status"=>"This one"},
      {"facility"=>"University of Wisconsin","status"=>"A different status"},
    ]
    p = Parsers::Ctgov.new("NCT123", 1, @api_data)
    allow(p).to receive(:location_search_term) { "University of Minnesota" }
    
    expect(p.calculated_status).to eq("This one")
  end

  it "#calculated_status with no location status" do
    @api_data["protocolSection"]["statusModule"]["overallStatus"] = "RECRUITING"
    @api_data["protocolSection"]["contactsLocationsModule"]["locations"] = [
      {"facility"=>"University of Minnesota"},
      {"facility"=>"University of Wisconsin"},
    ]
    p = Parsers::Ctgov.new("NCT123", 1, @api_data)
    allow(p).to receive(:location_search_term) { "University of Minnesota" }

    expect(p.calculated_status).to eq("RECRUITING")
  end
end
