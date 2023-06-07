require "rails_helper"

#TODO expect appropriate attrs can be updated based on protect_simple_description

RSpec.describe Admin::TrialsController, :type => :controller do

  before :each do 
    @user = create(:user)
    session[:user] = @user
    session[:role] = 'admin'
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

  describe "GET #edit" do
    it "responds to an edit request" do
      create(:system_info)
      trial = create(:trial, system_id: 'Test')
      get :edit, params: { id: trial.system_id }
      expect( assigns(:trial) ).to eq(trial)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    it "successfully changes a trial attribute" do
      create(:system_info)
      trial = create(:trial, pi_name: "Test Name")
      put :update, params: { id: trial.system_id, trial: { pi_name: "Updated value" }}
      trial.reload
      expect( trial.pi_name).to eq('Updated value')
    end

    context "given SystemInfo.protect_simple_description is false" do
      it "should successfully update simple_description" do
        create(:system_info, protect_simple_description: false)
        trial = create(:trial, simple_description: "Original Description")
        put :update, params: { id: trial.system_id, trial: { simple_description: "Updated value" }}
        trial.reload
        expect( trial.simple_description).to eq('Updated value')
      end

      it "should issue HTTP 200 but not update simple_description_override" do
        create(:system_info, protect_simple_description: false)
        trial = create(:trial, simple_description_override: "Original Description")
        put :update, params: { id: trial.system_id, trial: { simple_description_override: "Updated value" }}
        trial.reload
        expect( trial.simple_description_override).to eq('Original Description')
      end
    end

    context "given SystemInfo.protect_simple_description is true" do
      it "should successfully update simple_description_override" do
        create(:system_info, protect_simple_description: true)
        trial = create(:trial, simple_description_override: "Original Description")
        put :update, params: { id: trial.system_id, trial: { simple_description_override: "Updated value" }}
        trial.reload
        expect( trial.simple_description_override).to eq('Updated value')
      end

      it "should issue HTTP 200 but not update simple_description" do
        create(:system_info, protect_simple_description: true)
        trial = create(:trial, simple_description: "Original Description")
        put :update, params: { id: trial.system_id, trial: { simple_description: "Updated value" }}
        trial.reload
        expect( trial.simple_description).to eq('Original Description')
      end
    end
  end

  describe "GET #all_under_review " do
    before :each do
      create(:system_info)
    end

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
      create(:system_info)
      @trial = create(:trial, approved: false)
    end

    context "Admin user session" do
      it "marks the trial as approved" do
        put(:approved, params: {id: @trial.id}, session: session)
        @trial.reload
        expect(@trial.approved).to eq(true)
      end

      it "creates a new Approval with a succesful approval" do
        put(:approved, params: {id: @trial.id}, session: session)
        @trial.reload
        expect(Approval.last.trial_id).to eq(@trial.id)
        expect(Approval.last.user_id).to eq(session[:user]["id"])
      end
    end

    context "Non-admin user session" do
      it "does not mark the trial as approved" do
        session[:role] = 'some-other-role'
        put(:approved, params: {id: @trial.id}, session: session)
        @trial.reload
        expect(@trial.approved).to eq(false)
      end
    end
  end

  describe "get #under_review" do 
    before :each do
      create(:system_info)
    end

    it "responds succesfully with an HTTP 200 status code" do
      trial = create(:trial, system_id: 'Test', simple_description: "Test")
      get :under_review, params: {id: trial.id}

      expect(response).to have_http_status(200)
    end


    it "renders the pending_all_approval template" do
      trial = create(:trial, system_id: 'Test', simple_description: "Test")

      get :under_review, params: {id: trial.id}
      expect(response).to render_template("under_review")
    end
  end
end
