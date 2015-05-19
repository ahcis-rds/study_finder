class CategoriesController < ApplicationController
  def index
    @group = StudyFinder::VwGroupTrialCount.all.order(:group_name) 
  end
end