require "rails_helper"

RSpec.describe Admin::SystemController, :type => :controller do

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
    it "redirects to edit page" do
      get :index
      expect( redirect_to @system )
    end
  end

  describe "GET #edit" do
    it "responds to an edit request" do
      system = SystemInfo.create({ initials: 'UMN', school_name: 'University of Minnesota', system_name: 'StudyFinder', secret_key: 'test', default_email: 'noreply@umn.edu' })
      
      get :edit, params: { id: system.id }
      expect( assigns(:system) ).to eq(system)
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT #update" do
    before :each do
      @system = SystemInfo.create({ initials: 'UMN', school_name: 'University of Minnesota', system_name: 'StudyFinder', secret_key: 'test', default_email: 'noreply@umn.edu' })
    end

    it "successfully updates attributes" do
      put :update, params: { id: @system, system_info: {school_name: 'Testing...', display_groups_page: false } }
      @system.reload
      
      expect( @system.school_name ).to eq('Testing...')
      expect( @system.display_groups_page ).to eq(false)
      expect( redirect_to @system )
    end
  end
end
