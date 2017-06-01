class Admin::ConditionsController < ApplicationController
  before_filter :authorize_admin

  def recent_as

    d = params.has_key?('days') ? params[:days].to_i : 30
    @conditions = StudyFinder::Condition.recent_as(d.days).paginate(page: params[:page])

    add_breadcrumb 'Reports'
    add_breadcrumb 'Recent Conditions'
    
  end

end
