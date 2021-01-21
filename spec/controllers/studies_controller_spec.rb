require "rails_helper"

RSpec.describe StudiesController, :type => :controller do

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "handles empty groups" do
      group = Group.create(group_name: "empty group")

      get :index, params: { search: { category: group.id } }

      expect(response).to have_http_status(200)
    end
  end

  describe "GET #show" do
    
    before {
      @study = Trial.create({
        system_id: 'NCT001test',
        brief_title: 'test',
        official_title: 'test'
      })
    }

    it "redirects study show page if disabled" do
      SystemInfo.destroy_all
      @system_info = SystemInfo.create({ initials: 'UMN', school_name: 'University of Minnesota', system_name: 'StudyFinder', secret_key: 'test', default_email: 'noreply@umn.edu', display_study_show_page: false})
      
      get :show, params: { id: @study.id }

      expect(response).to redirect_to(studies_url)
      expect(flash[:success]).to eq('Apologies, This page is not available.')
    end

    it "successfully renders study show page if enabled" do
      SystemInfo.destroy_all
      @system_info = SystemInfo.create({ initials: 'UMN', school_name: 'University of Minnesota', system_name: 'StudyFinder', secret_key: 'test', default_email: 'noreply@umn.edu', display_study_show_page: true})
      
      get :show, params: { id: @study.id }

      expect(response).to have_http_status(200)
      expect(response).to render_template("show")
    end
  end

end
