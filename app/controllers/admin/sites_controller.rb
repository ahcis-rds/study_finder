class Admin::SitesController < ApplicationController
  before_action :authorize_admin
  
  def index
    @sites = StudyFinder::Site.all

    add_breadcrumb 'Sites'
  end

  def new
    @site = StudyFinder::Site.new

    add_breadcrumb 'Sites', :admin_sites_path
    add_breadcrumb 'Add Site'
  end

  def create
    @site = StudyFinder::Site.new(site_params)
    if @site.save(@site)
      redirect_to admin_sites_path, flash: { success: 'Site added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @site = StudyFinder::Site.find(params[:id])
    add_breadcrumb 'Sites', :admin_sites_path
    add_breadcrumb 'Edit Site'
  end

  def update
    @site = StudyFinder::Site.find(params[:id])

    if @site.update(site_params)
      redirect_to edit_admin_site_path(params[:id]), flash: { success: 'Site updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @site = StudyFinder::Site.find(params[:id])
    if @site.destroy
      redirect_to admin_sites_path, flash: { success: 'Site removed successfully' }
    else
      redirect_to admin_sites_path, flash: { error: 'Unable to remove site' }
    end
  end

  private
    def site_params
      params.require(:study_finder_site).permit(:site_name, :address, :city, :state, :zip)
    end
end