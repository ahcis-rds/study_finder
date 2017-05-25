class Admin::ReportsController < ApplicationController
  before_filter :authorize_admin

  def index
    add_breadcrumb 'Reports'
  end

end
