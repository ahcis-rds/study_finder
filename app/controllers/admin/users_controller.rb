class Admin::UsersController < ApplicationController
  before_action :authorize_admin
  
  def index
    @users = User.all

    add_breadcrumb 'Users'
  end

  def new
    @user = User.new

    add_breadcrumb 'Users', :admin_users_path
    add_breadcrumb 'Add User'
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, flash: { success: 'User added successfully' }
    else
      render action: 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    
    add_breadcrumb 'Users', :admin_users_path
    add_breadcrumb 'Edit User'
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to edit_admin_user_path(params[:id]), flash: { success: 'User updated successfully' }
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to admin_users_path, flash: { success: 'User removed successfully' }
    else
      redirect_to admin_users_path, flash: { error: 'Unable to remove user' }
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :internet_id, :first_name, :last_name, :phone)
    end
end