require "rails_helper"

RSpec.describe Admin::GroupsController, :type => :controller do

  before :each do
    @user = create(:user)
    session[:user] = @user
    session[:role] = 'admin'
  end

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
      group = create(:group)
      get :edit, params: { id: group.id }
      expect( assigns(:group) ).to eq(group)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    before :each do
      @group = create(:group)
      @condition = create(:condition)
    end

    it "successfully changes group's attributes" do
      put :update, params: { id: @group, group: {group_name: 'Testing...', condition_ids: [@condition.id] } }
      @group.reload
      
      expect( @group.group_name ).to eq('Testing...')
      expect( @group.conditions.size ).to eq(1)
    end

    it "redirects to the updated contact" do
      put :update, params: { id: @group, group: {group_name: 'Testing...', condition_ids: [@condition.id] } }
      expect( redirect_to @group )
    end

    it "adds a new subgroup" do
      expected = ["Blah", "Another thing"]
      put :update, params: { id: @group, group: {group_name: 'Testing...', condition_ids: [@condition.id], subgroups: expected } }
      actual = @group.subgroups.map { |subgroup| subgroup.name }

      expect(expected).to eq(actual)
    end

    it "removes a subgroup" do
      @group.subgroups.create(name: "A subgroup")
      @group.subgroups.create(name: "Another subgroup")

      put :update, params: { id: @group, group: {group_name: 'Testing...', condition_ids: [@condition.id], subgroups: ["A subgroup"] } }

      @group.reload
      actual = @group.subgroups.map { |subgroup| subgroup.name }

      expect(actual).to eq(["A subgroup"])
    end

  end
end
