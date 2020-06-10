class Admin::DiseaseSitesController < ApplicationController
  before_action :authorize_admin
  
  def index
    @sites = DiseaseSite.includes(:group).all
    add_breadcrumb 'Disease Site'
  end

  def new
    @site = DiseaseSite.new

    add_breadcrumb 'Disease Site', :admin_disease_sites_path
    add_breadcrumb 'Add Disease Site'
  end

  def create
    @site = DiseaseSite.new(site_params)
    if @site.save(@site)
      redirect_to admin_disease_sites_path, flash: { success: 'Site added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @site = DiseaseSite.find(params[:id])
    add_breadcrumb 'Disease Sites', :admin_disease_sites_path
    add_breadcrumb 'Edit Site'
  end

  def update
    @site = DiseaseSite.find(params[:id])

    if @site.update(site_params)
      redirect_to edit_admin_disease_site_path(params[:id]), flash: { success: 'Site updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @site = DiseaseSite.find(params[:id])
    if @site.destroy
      redirect_to admin_disease_sites_path, flash: { success: 'Site removed successfully' }
    else
      redirect_to admin_disease_sites_path, flash: { error: 'Unable to remove site' }
    end
  end

  
  private
    def site_params
      params.require(:study_finder_disease_site).permit(:disease_site_name, :group_id)
    end

end