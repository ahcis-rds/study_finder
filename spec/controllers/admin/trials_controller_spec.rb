require "rails_helper"

RSpec.describe Admin::TrialsController, :type => :controller do

  before {
    session.update({
      email: 'kadrm002@umn.edu',
      internet_id: 'kadrm002',
      first_name: 'Jason',
      last_name: 'Kadrmas',
      role: 'admin',
      id: 4
    })
  }

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET #edit" do
    it "responds to an edit request" do
      trial = Trial.create({ system_id: 'Test' })
      get :edit, params: { id: trial.system_id }
      expect( assigns(:trial) ).to eq(trial)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    before :each do
      @trial = Trial.create({ system_id: 'Test', simple_description: "Test" })
    end

    it "successfully changes trial's simple_description" do
      put :update, params: { id: @trial.system_id, trial: { simple_description: "Updated value" }}
      @trial.reload
      expect( @trial.simple_description).to eq('Updated value')
      
    end
  end

  describe "GET #all_pending_approval " do


    it "responds succesfully with an HTTP 200 status code" do
      get :all_pending_approval
      expect(response).to have_http_status(200)
    end

    it "renders the pending_all_approval template" do
      get :all_pending_approval
      expect(response).to render_template("all_pending_approval")
    end

  end

  describe "approval" do
    before :each do
      @trial = Trial.create({ system_id: 'Test', simple_description: "Test" })
    end

    it "marks the trial as approved" do
      put(:approved, params: {id: @trial.id}, session: {:user => {"id" => 5}})
      @trial.reload
      expect(@trial.approved).to eq(true)
    end

    it "creates a new Approval with a succesful approval" do
      put(:approved, params: {id: @trial.id}, session: {:user => {"id" => 5}})
      @trial.reload
      expect(Approval.last.trial_id).to eq(@trial.id)
      expect(Approval.last.user_id).to eq(session[:user]["id"])
    end
    

  end

  describe "get #pending_approval" do 

    it "responds succesfully with an HTTP 200 status code" do
      trial = Trial.create({ system_id: 'Test', simple_description: "Test" })
      get :pending_approval, params: {id: trial.id}

      expect(response).to have_http_status(200)
    end


    it "renders the pending_all_approval template" do
      trial = Trial.create({ system_id: 'Test', simple_description: "Test" })

      get :pending_approval, params: {id: trial.id}
      expect(response).to render_template("pending_approval")
    end

    
  end
end
