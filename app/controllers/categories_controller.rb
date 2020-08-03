class CategoriesController < ApplicationController
  def index
    @groups = Group.order(:group_name).all
  end
end