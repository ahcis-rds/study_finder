class Admin::ReportsController < ApplicationController
  before_action :authorize_admin

  def index
    add_breadcrumb 'Reports'
  end

end
