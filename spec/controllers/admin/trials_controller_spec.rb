require "rails_helper"

RSpec.describe Admin::TrialsController, :type => :controller do

  before :each do 
    @user = create(:user)
    session[:user] = @user
    session[:role] = 'admin'
  end

  describe "GET #index" do
    context "trial_approval system setting is off" do
      before :each do
        create(:system_info, trial_approval: false)
      end

      it "responds successfully with an HTTP 200 status code" do
        get :index
        expect(response).to have_http_status(200)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end

      it "returns trials where visible is true, ignoring approved" do
        t1 = create(:trial, visible: true, approved: false)
        t2 = create(:trial, visible: false, approved: false)
        t3 = create(:trial, visible: true, approved: true)
        t4 = create(:trial, visible: false, approved: true)
        get :index
        expect(assigns(:trials).count).to eq(2)

        t5 = create(:trial, visible: true, approved: false)
        get :index
        expect(assigns(:trials).count).to eq(3)

        t6 = create(:trial, visible: true, approved: true)
        get :index
        expect(assigns(:trials).count).to eq(4)
      end
    end

    context "trial_approval system setting is on" do
      before :each do
        create(:system_info, trial_approval: true)
      end

      it "responds successfully with an HTTP 200 status code" do
        get :index
        expect(response).to have_http_status(200)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end

      it "returns trials where visible is true and approved is true" do
        t1 = create(:trial, visible: true, approved: false)
        t2 = create(:trial, visible: false, approved: false)
        t3 = create(:trial, visible: true, approved: true)
        t4 = create(:trial, visible: false, approved: true)
        get :index
        expect(assigns(:trials).count).to eq(1)

        t5 = create(:trial, visible: true, approved: false)
        get :index
        expect(assigns(:trials).count).to eq(1)

        t6 = create(:trial, visible: true, approved: true)
        get :index
        expect(assigns(:trials).count).to eq(2)
      end
    end
  end

  describe "GET #index with search term" do
    context "trial_approval system setting is off" do
      before :each do
        create(:system_info, trial_approval: false)
      end

      it "returns trials where visible is true and search term matches, ignoring approved" do
        t1 = create(:trial, brief_title: 'FOOBAR', visible: true, approved: false)
        t2 = create(:trial, brief_title: 'FOOBAR', visible: false, approved: false)
        t3 = create(:trial, brief_title: 'BARBAZ', visible: true, approved: true)
        t4 = create(:trial, brief_title: 'BAZBOO', visible: false, approved: true)
        sleep 2

        get :index, params: { q: 'FOOBAR' }
        expect(assigns(:trials).count).to eq(1)

        get :index, params: { q: 'BARBAZ' }
        expect(assigns(:trials).count).to eq(1)

        get :index, params: { q: 'BAZBOO' }
        expect(assigns(:trials).count).to eq(0)

        t4.update(visible: true)
        get :index, params: { q: 'BAZBOO' }
        expect(assigns(:trials).count).to eq(0)

        get :index, params: { q: 'BINGO' }
        expect(assigns(:trials).count).to eq(0)

        t5 = create(:trial, brief_title: 'BINGO', visible: true, approved: false)
        sleep 2

        get :index, params: { q: 'BINGO' }
        expect(assigns(:trials).count).to eq(1)
      end
    end

    context "trial_approval system setting is on" do
      before :each do
        create(:system_info, trial_approval: true)
      end

      it "returns trials where visible is true, approved is true, and search term matches" do
        t1 = create(:trial, brief_title: 'FOOBAR', visible: true, approved: true)
        t2 = create(:trial, brief_title: 'FOOBAR', visible: true, approved: false)
        t3 = create(:trial, brief_title: 'BARBAZ', visible: false, approved: true)
        t4 = create(:trial, brief_title: 'BAZBOO', visible: false, approved: false)
        sleep 2

        get :index, params: { q: 'FOOBAR' }
        expect(assigns(:trials).count).to eq(1)

        get :index, params: { q: 'BARBAZ' }
        expect(assigns(:trials).count).to eq(0)

        get :index, params: { q: 'BAZBOO' }
        expect(assigns(:trials).count).to eq(0)

        get :index, params: { q: 'BINGO' }
        expect(assigns(:trials).count).to eq(0)

        t5 = create(:trial, brief_title: 'BINGO', visible: true, approved: true)
        sleep 2

        get :index, params: { q: 'BINGO' }
        expect(assigns(:trials).count).to eq(1)
      end
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
  end

  describe "GET #all_under_review" do
    before :each do
      create(:system_info, trial_approval: true)
    end

    it "responds succesfully with an HTTP 200 status code" do
      get :all_under_review
      expect(response).to have_http_status(200)
    end

    it "renders the pending_all_approval template" do
      get :all_under_review
      expect(response).to render_template("all_under_review")
    end

    it "returns trials where visible is true and approved is false" do
      t1 = create(:trial, visible: true, approved: false)
      t2 = create(:trial, visible: false, approved: false)
      t3 = create(:trial, visible: true, approved: true)
      t4 = create(:trial, visible: false, approved: true)
      get :all_under_review
      expect(assigns(:trials).count).to eq(1)

      t5 = create(:trial, visible: true, approved: false)
      get :all_under_review
      expect(assigns(:trials).count).to eq(2)

      t6 = create(:trial, visible: true, approved: true)
      get :all_under_review
      expect(assigns(:trials).count).to eq(2)
    end

    it "returns trials where visible is true, approved is false, and search term matches" do
      t1 = create(:trial, brief_title: 'FOOBAR', visible: true, approved: true)
      t2 = create(:trial, brief_title: 'FOOBAR', visible: true, approved: false)
      t3 = create(:trial, brief_title: 'BARBAZ', visible: false, approved: true)
      t4 = create(:trial, brief_title: 'BAZBOO', visible: false, approved: false)
      sleep 2

      get :all_under_review, params: { q: 'FOOBAR' }
      expect(assigns(:trials).count).to eq(1)

      get :all_under_review, params: { q: 'BARBAZ' }
      expect(assigns(:trials).count).to eq(0)

      get :all_under_review, params: { q: 'BAZBOO' }
      expect(assigns(:trials).count).to eq(0)

      get :all_under_review, params: { q: 'BINGO' }
      expect(assigns(:trials).count).to eq(0)

      t5 = create(:trial, brief_title: 'BINGO', visible: true, approved: false)
      sleep 2

      get :all_under_review, params: { q: 'BINGO' }
      expect(assigns(:trials).count).to eq(1)
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
