require "rails_helper"

#TODO expect appropriate attrs can be updated based on protect_simple_description

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
      @system_info = SystemInfo.create(secret_key: 'asdf', default_email: 'asdf@umn.edu', initials: 'UMN', school_name: 'University of Minnesota')
      @trial = Trial.create({ system_id: 'Test', brief_title: "Test Title", simple_description: "Test Description" })
    end

    it "successfully changes trial's brief_title" do
      put :update, params: { id: @trial.system_id, trial: { brief_title: "Updated value" }}
      @trial.reload
      expect( @trial.brief_title).to eq('Updated value')
    end

    context "given an attempt to update simple_description" do
      it "should succeed if SystemInfo.protect_simple_description is false" do
        @system_info.update(protect_simple_description: false)
        put :update, params: { id: @trial.system_id, trial: { simple_description: "Updated value" }}
        @trial.reload
        expect( @trial.brief_title).to eq('Updated value')
      end

      it "should succeed but not update the attr if SystemInfo.protect_simple_description is true" do
        @system_info.update(protect_simple_description: true)
        put :update, params: { id: @trial.system_id, trial: { simple_description: "Test Description" }}
        @trial.reload
        expect( @trial.brief_title).to eq('Updated value')
      end
    end
  end

  describe "GET #all_under_review " do
    it "responds succesfully with an HTTP 200 status code" do
      get :all_under_review
      expect(response).to have_http_status(200)
    end

    it "renders the pending_all_approval template" do
      get :all_under_review
      expect(response).to render_template("all_under_review")
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

  describe "get #under_review" do 
    it "responds succesfully with an HTTP 200 status code" do
      trial = Trial.create({ system_id: 'Test', simple_description: "Test" })
      get :under_review, params: {id: trial.id}

      expect(response).to have_http_status(200)
    end


    it "renders the pending_all_approval template" do
      trial = Trial.create({ system_id: 'Test', simple_description: "Test" })

      get :under_review, params: {id: trial.id}
      expect(response).to render_template("under_review")
    end
  end
end
