require "rails_helper"

RSpec.describe Admin::GroupsController, :type => :controller do

  before {
    session.update({
      email: 'kadrm002@umn.edu',
      internet_id: 'kadrm002',
      first_name: 'Jason',
      last_name: 'Kadrmas',
      role: 'admin'
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

  describe "GET #edit" do
    it "responds to an edit request" do
      group = StudyFinder::Group.create({ group_name: 'Test' })
      get :edit, params: { id: group.id }
      expect( assigns(:group) ).to eq(group)
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    before :each do
      @group = StudyFinder::Group.create({ group_name: 'Test' })
      @condition = StudyFinder::Condition.create({ condition: 'Test Condition' })
    end

    it "successfully changes group's attributes" do
      put :update, params: { id: @group, group_name: 'Testing...', condition_ids: [@condition.id] }
      @group.reload
      
      expect( @group.group_name ).to eq('Testing...')
      expect( @group.conditions.size ).to eq(1)
    end

    it "redirects to the updated contact" do
      put :update, params: { id: @group, group_name: 'Testing...', condition_ids: [@condition.id] }
      expect( redirect_to @group )
    end

    it "adds a new subgroup" do
      put :update, params: { id: @group, tags: "This is a subgroup, And so is this, And this one too"}
      expect( redirect_to @group )
      expect(@group.subgroups.count).to eq(3)
    end

    it "removes a subgroup" do
      put :update, params: { id: @group, tags: "This is a subgroup" }
      expect( redirect_to @group )
      expect(@group.subgroups.count).to eq(1)
    end

    it "removes all subgroups" do
      put :update, params: { id: @group, tags: "" }
      expect( redirect_to @group )
      expect(@group.subgroups).to be_empty
    end
  end
end
