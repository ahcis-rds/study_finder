require "rails_helper"

RSpec.describe Admin::SystemController, :type => :controller do

  before {
    @user = create(:user)
    session[:user] = @user
    session[:role] = 'admin'
  }

  before :each do
    SystemInfo.destroy_all
  end

  describe "GET #index" do
    it "redirects to edit page" do
      si = create(:system_info)
      get :index
      expect( redirect_to si )
    end
  end

  describe "GET #edit" do
    it "responds to an edit request" do
      si = create(:system_info)      
      get :edit, params: { id: si.id }
      expect( assigns(:system_info) ).to eq(si)
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    it "successfully updates attributes" do
      si = create(:system_info)
      put :update, params: { id: si.id, system_info: {school_name: 'Testing...', display_groups_page: false } }
      si.reload
      
      expect( si.school_name ).to eq('Testing...')
      expect( si.display_groups_page ).to eq(false)
      expect( redirect_to si )
    end
  end
end
