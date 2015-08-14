class CategoriesController < ApplicationController
  def index
    @groups = StudyFinder::Group.order(:group_name).all
  end
end