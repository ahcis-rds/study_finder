class Admin::ApprovalsController < ApplicationController
  before_action :authorize_admin

  def index
    @approvals = Approval.order('updated_at DESC')

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Under Review', :admin_all_trials_under_review_path
  end

end
