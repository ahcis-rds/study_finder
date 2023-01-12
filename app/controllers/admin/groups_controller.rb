class Admin::GroupsController < ApplicationController
  before_action :authorize_admin

  require 'csv'
  
  def index
    @groups = Group.all.order(:group_name)

    add_breadcrumb 'Groups'
  end

  def new
    @group = Group.new
    @conditions = Condition.all.order(:condition)

    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Add Group'
  end

  def create
    @group = Group.new(group_params)

    build_subgroups

    if @group.save(@group)
      redirect_to admin_groups_path, flash: { success: 'Group added successfully' }
    else
      @conditions = Condition.all.order(:condition)
      render action: 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    @conditions = Condition.all.order(:condition)
    
    add_breadcrumb 'Groups', :admin_groups_path
    add_breadcrumb 'Edit Group'

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "#{friendly_filename(@group.group_name.try(:downcase))}_categories.csv" }
    end
  end

  def update
    @group = Group.find(params[:id])

    build_subgroups

    if @group.update(group_params)
      redirect_to edit_admin_group_path(params[:id]), flash: { success: 'Group updated successfully' }
    else
      @conditions = Condition.all.order(:condition)
      render 'edit'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if @group.destroy
      redirect_to admin_groups_path, flash: { success: 'Group removed successfully' }
    else
      redirect_to admin_groups_path, flash: { error: 'Unable to remove group' }
    end
  end

  def reindex
    Trial.import force: true

    add_breadcrumb 'Groups', :admin_groups_path
  end

  private
    def group_params
      params.require(:group).permit(:group_name, :children, :adults, :healthy_volunteers, condition_ids: [])
    end

    def build_subgroups
      @group.subgroups.destroy_all
      @group.subgroups = Array(params[:group][:subgroups]).map do |subgroup|
        @group.subgroups.build(name: subgroup)
      end
    end

    def generate_csv
      column_names = ['Condition Name', 'Selected']
      group_conditions = @group.conditions

      CSV.generate do |csv|
        csv << column_names
        @conditions.each do |item|
          selected = !group_conditions.select { |gc| gc.id == item.id }.empty?
          row = [item.condition, (selected) ? 'X': '']
          csv << row
        end
      end
    end

    def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
        .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
        .gsub(/\s+/, '_')
    end

end