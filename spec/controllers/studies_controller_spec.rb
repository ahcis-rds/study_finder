require "rails_helper"

RSpec.describe StudiesController, :type => :controller do

  describe "GET #index" do
    before :each do
      SystemInfo.destroy_all
      create(:system_info)
      @study = create(:trial)
    end

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
    before :each do
      SystemInfo.destroy_all
    end
    
    it "redirects study show page if study is not visible" do
      create(:system_info, display_study_show_page: true)
      @study = create(:trial, visible: false)
      get :show, params: { id: @study.id }

      expect(response).to redirect_to(studies_url)
      expect(flash[:success]).to eq('Apologies, this page is not available.')
    end 

    it "redirects study show page if disabled" do
      create(:system_info, display_study_show_page: false)
      @study = create(:trial, visible: true)
      get :show, params: { id: @study.id }

      expect(response).to redirect_to(studies_url)
      expect(flash[:success]).to eq('Apologies, this page is not available.')
    end

    it "successfully renders study show page if enabled and study is visible" do
      create(:system_info, display_study_show_page: true)
      @study = create(:trial, visible: true)
      get :show, params: { id: @study.id }

      expect(response).to have_http_status(200)
      expect(response).to render_template("show")
    end
  end

end
