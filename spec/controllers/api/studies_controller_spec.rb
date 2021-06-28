require "rails_helper"

describe Api::StudiesController do
  context "unauthenticated requests" do
    it "are rejected" do
      get :show, params: { id: "NCT123" }
      expect(response).to have_http_status(401)
    end
  end

  context "authenticated requests" do
    before do
      api_key = ApiKey.create!(name: "blah")
      request.headers["Authorization"] = "bearer #{api_key.token}"
    end

    it "can read studies" do
      study = Trial.create!(system_id: "NCT123")

      get :show, params: { id: study.system_id, format: :json }

      expect(response).to have_http_status(200)
    end

    it "can update studies" do
      study = Trial.create!(system_id: "NCT345")
      attributes_to_update = {
        contact_override: "blah@example.com",
        contact_override_first_name: "Testy",
        contact_override_last_name: "McTesterson",
        irb_number: "1234567890",
        pi_id: "somepi@example.com",
        pi_name: "Some PI, M.D.",
        recruiting: true,
        simple_description: "This is a short description",
        brief_title: "This is a brief title",
        visible: true
      }

      patch :update, params: attributes_to_update.merge(id: "NCT345")

      expect(response).to have_http_status(200)

      study.reload

      attributes_to_update.each do |attribute, value|
        expect(study[attribute]).to eq(value)
      end
    end

    it "can create studies" do
      attributes = {
        system_id: "SOME-ID",
        contact_override: "blah@example.com",
        contact_override_first_name: "Testy",
        contact_override_last_name: "McTesterson",
        irb_number: "1234567890",
        pi_id: "somepi@example.com",
        pi_name: "Some PI, M.D.",
        recruiting: true,
        simple_description: "This is a short description",
        brief_title: "This is a brief title",
        visible: true
      }

      post :create, params: attributes

      trial = Trial.find_by(system_id: "SOME-ID")

      attributes.each do |attribute, value|
        expect(trial[attribute]).to eq(value)
      end
    end

    it "can create with conditions" do
      conditions = ["Something", "Something else"]

      post :create, params: { system_id: "BLAH123", conditions: conditions }

      trial = Trial.find_by(system_id: "BLAH123")

      expect(trial.condition_values.sort).to eq(conditions)
    end

    it "can create with keywords" do
      keywords = ["Something", "Something else"]

      post :create, params: { system_id: "BLAH123", keywords: keywords }

      trial = Trial.find_by(system_id: "BLAH123")

      expect(trial.keyword_values.sort).to eq(keywords)
    end

    it "can update conditions" do
      study = Trial.create!(system_id: "ASDF123")
      conditions = ["A condition", "Another one"]

      post :update, params: { id: "ASDF123", conditions: conditions }

      study.reload
      expect(study.condition_values.sort).to eq(conditions)
    end

    it "can create with locations" do
      locations = [
        {
          "name": "Masonic Cancer Center, University of Minnesota",
          "city": "Minneapolis",
          "state": "Minnesota",
          "zip": "55455",
          "country": "United States"
        },
        {
          "name": "University of Wisconsin Hospital and Clinics",
          "city": "Madison",
          "state": "Wisconsin",
          "zip": "53792",
          "country": "United States"
        }
      ]

      post :create, params: { system_id: "BLAH123", locations: locations }

      trial = Trial.find_by(system_id: "BLAH123")

      locations.each do |location|
        expect(trial.locations.as_json).to include(location)
      end
    end

    it "can update locations" do
      trial = Trial.create!(system_id: "ASDF123")
      locations = [
        {
          "name": "Test location 1",
          "city": "Minneapolis",
          "state": "Minnesota",
          "zip": "55455",
          "country": "United States"
        },
        {
          "name": "Test location 2",
          "city": "Madison",
          "state": "Wisconsin",
          "zip": "53792",
          "country": "United States"
        }
      ]

      post :update, params: { id: "ASDF123", locations: locations }

      trial.reload

      locations.each do |location|
        expect(trial.locations.as_json).to include(location)
      end
    end
  end
end

