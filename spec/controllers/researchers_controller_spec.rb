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
      trial = StudyFinder::Trial.create({ brief_title: 'Testing a title', system_id: 'NCT000001' })

      get :edit, id: trial.system_id
      
      expect( assigns(:trial) ).to eq(trial)
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  # describe "PUT #update" do
  #   before :each do
  #     @group = StudyFinder::Group.create({ group_name: 'Test' })
  #     @condition = StudyFinder::Condition.create({ condition: 'Test Condition' })
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