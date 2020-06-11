require "rails_helper"

RSpec.describe ResearchersController, :type => :controller do

  before {
    session.update({
      email: 'kadrm002@umn.edu',
      internet_id: 'kadrm002',
      first_name: 'Jason',
      last_name: 'Kadrmas',
      role: 'researcher'
    })

    @system_info = SystemInfo.create({
      initials: 'UMN',
      school_name: 'University of Minnesota',
      system_name: 'Study Finder',
      system_header: 'Make A Difference. Get Involved.',
      system_description: "Test Description",
      researcher_description: "Test",
      search_term: 'University of Minnesota',
      default_url: 'http://studyfinder.umn.edu',
      default_email: 'sfinder@umn.edu',
      display_all_locations: false,
      secret_key: 'test',
      contact_email_suffix: '@umn.edu'
    })
  }

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET #search" do
    it "responds successfully with an HTTP 200 status code" do
      get :search
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the search template" do
      get :search
      expect(response).to render_template("search")
    end
  end

  describe "GET #edit" do
    it "responds to an edit request" do
      trial = Trial.create({ brief_title: 'Testing a title', system_id: 'NCT000001' })

      get :edit, params: { id: trial.system_id }
      
      expect( assigns(:trial) ).to eq(trial)
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    it "trial with override information" do
      trial = Trial.create({ brief_title: 'Testing a title', system_id: 'NCT000001' })

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
      
      put :update, params: { id: trial.system_id, trial: study_finder_trial, secret_key: @system_info.secret_key }
      
      expect( assigns(:trial).simple_description ).to eq(simple_description)
      expect( assigns(:trial).contact_override ).to eq(contact_override)
      expect( assigns(:trial).contact_override_first_name ).to eq(contact_override_first_name)
      expect( assigns(:trial).contact_override_last_name ).to eq(contact_override_last_name)

      expect(response).to redirect_to(edit_researcher_path(trial.system_id))
      expect(flash[:success]).to eq('Trial updated successfully')
    end

    it "fails when a secret_key is not provided" do
      trial = Trial.create({ brief_title: 'Testing a title', system_id: 'NCT000001' })

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
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(flash[:notice]).to eq('The secret key you entered was incorrect.')
    end

    it "fails when an invalid secret_key is added" do
      trial = Trial.create({ brief_title: 'Testing a title', system_id: 'NCT000001' })

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
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(flash[:notice]).to eq('The secret key you entered was incorrect.')
    end
  end

  # describe "PUT #update" do
  #   before :each do
  #     @group = Group.create({ group_name: 'Test' })
  #     @condition = Condition.create({ condition: 'Test Condition' })
  #   end

  #   it "successfully changes group's attributes" do
  #     put :update, id: @group, group_name: 'Testing...', condition_ids: [@condition.id]
  #     @group.reload
      
  #     expect( @group.group_name ).to eq('Testing...')
  #     expect( @group.conditions.size ).to eq(1)
  #   end

  #   it "redirects to the updated contact" do
  #     put :update, id: @group, group_name: 'Testing...', condition_ids: [@condition.id]
  #     expect( redirect_to @group )
  #   end

  # end
end
