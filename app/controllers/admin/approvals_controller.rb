class Admin::ApprovalsController < ApplicationController
  before_action :authorize_admin

  def index
    @approvals = Approval.order('updated_at DESC')

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'All Pending Approvals', :admin_all_trials_pending_approval_path
  end

end
