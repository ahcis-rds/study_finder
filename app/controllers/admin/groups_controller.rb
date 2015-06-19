class Admin::GroupsController < ApplicationController
  before_filter :authorize_admin
  
  def index
    @groups = StudyFinder::Group.all

    add_breadcrumb 'Groups'
  end

  def new
    @group = StudyFinder::Group.new
    @conditions = StudyFinder::Condition.all.order(:condition)

    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Add Group'
  end

  def create
    @group = StudyFinder::Group.new(group_params)
    if @group.save(@group)
      redirect_to admin_groups_path, flash: { success: 'Group added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @group = StudyFinder::Group.find(params[:id])
    @conditions = StudyFinder::Condition.all.order(:condition)
    
    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Edit Group'
  end

  def update
    @group = StudyFinder::Group.find(params[:id])
    if @group.update(group_params)
      unless params[:tags].nil?
        StudyFinder::Subgroup.delete_all({ group_id: @group.id })
        params[:tags][0].split(',').each do |t|
          StudyFinder::Subgroup.create!({
            group_id: @group.id,
            name: t
          })
        end
      end
      redirect_to edit_admin_group_path(params[:id]), flash: { success: 'Group updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @group = StudyFinder::Group.find(params[:id])
    if @group.destroy
      redirect_to admin_groups_path, flash: { success: 'Group removed successfully' }
    else
      redirect_to admin_groups_path, flash: { error: 'Unable to remove group' }
    end
  end

  private
    def group_params
      params.permit(:group_name, condition_ids: [])
    end
end