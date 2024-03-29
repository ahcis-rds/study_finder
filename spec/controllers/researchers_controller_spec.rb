require "rails_helper"

RSpec.describe ResearchersController, :type => :controller do

  before :each do
    @user = create(:user)
    session[:user] = @user
    session[:role] = 'researcher'
  end

  describe "GET #index" do
    before :each do 
      create(:system_info)
    end

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET #search" do
    before :each do 
      create(:system_info)
    end

    it "responds successfully with an HTTP 200 status code" do
      get :search
      expect(response).to have_http_status(200)
    end

    it "renders the search template" do
      get :search
      expect(response).to render_template("search")
    end
  end

  describe "GET #edit" do
    before :each do 
      create(:system_info)
    end

    it "responds to an edit request" do
      trial = create(:trial, brief_title: 'Testing a title', system_id: 'NCT000001')

      get :edit, params: { id: trial.system_id }
      
      expect( assigns(:trial) ).to eq(trial)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    it "successfully changes trial attribute" do
      create(:system_info)
      trial = create(:trial, contact_override_last_name: "Test Name")
      put :update, params: { id: trial.system_id, trial: { contact_override_last_name: "Updated value" }, secret_key: SystemInfo.secret_key}
      trial.reload
      expect( trial.contact_override_last_name).to eq('Updated value')
    end

    it "trial with override information" do
      create(:system_info)
      trial = create(:trial, brief_title: 'Testing a title', system_id: 'NCT000001' )

      simple_description_override = 'Testing adding a simple_description_override'
      contact_override = 'jim@aol.com'
      contact_override_first_name = 'Jim'
      contact_override_last_name = 'Smith'

      study_finder_trial = {
        simple_description_override: simple_description_override, 
        contact_override: contact_override, 
        contact_override_first_name: contact_override_first_name, 
        contact_override_last_name: contact_override_last_name
      }
      
      put :update, params: { id: trial.system_id, trial: study_finder_trial, secret_key: SystemInfo.secret_key }
      
      expect( assigns(:trial).simple_description_override).to eq(simple_description_override)
      expect( assigns(:trial).contact_override ).to eq(contact_override)
      expect( assigns(:trial).contact_override_first_name ).to eq(contact_override_first_name)
      expect( assigns(:trial).contact_override_last_name ).to eq(contact_override_last_name)

      expect(response).to redirect_to(edit_researcher_path(trial.system_id))
      expect(flash[:success]).to eq('Trial updated successfully')
    end

    it "fails when a secret_key is not provided" do
      create(:system_info)
      trial = create(:trial, brief_title: 'Testing a title', system_id: 'NCT000001')

      simple_description = 'Testing adding a simple_description'
      contact_override = 'jim@aol.com'
      contact_override_first_name = 'Jim'
      contact_override_last_name = 'Smith'

      study_finder_trial = {
        simple_description: simple_description, 
        contact_override: contact_override, 
        contact_override_first_name: contact_override_first_name, 
        contact_override_last_name: contact_override_last_name
      }
      
      put :update, params: { id: trial.system_id, study_finder_trial: study_finder_trial }
      expect(response).to have_http_status(200)
      expect(flash[:notice]).to eq('The secret key you entered was incorrect.')
    end

    it "fails when an invalid secret_key is added" do
      create(:system_info)
      trial = create(:trial, brief_title: 'Testing a title', system_id: 'NCT000001')

      simple_description = 'Testing adding a simple_description'
      contact_override = 'jim@aol.com'
      contact_override_first_name = 'Jim'
      contact_override_last_name = 'Smith'

      study_finder_trial = {
        simple_description: simple_description, 
        contact_override: contact_override, 
        contact_override_first_name: contact_override_first_name, 
        contact_override_last_name: contact_override_last_name
      }
      
      put :update, params: { id: trial.system_id, study_finder_trial: study_finder_trial, secret_key: 'invalid_key' }
      expect(response).to have_http_status(200)
      expect(flash[:notice]).to eq('The secret key you entered was incorrect.')
    end
  end
end
