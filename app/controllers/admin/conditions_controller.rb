class Admin::ConditionsController < ApplicationController
  before_action :authorize_admin

  def recent_as

  	@start_date = (params[:start_date].nil?) ? (DateTime.now - 30.days).strftime('%m/%d/%Y') : params[:start_date]
  	@end_date = (params[:end_date].nil?) ? DateTime.now.strftime('%m/%d/%Y') : params[:end_date]
    @conditions = StudyFinder::Condition.find_range(@start_date, @end_date)

    add_breadcrumb 'Reports'
    add_breadcrumb 'Recent Conditions'

    respond_to do |format|
    	format.html

    	format.xls do
    		response.headers['Content-Type'] = 'application/vnd.ms-excel'
    		response.headers['Content-Disposition'] = "attachment; filename=\"study_finder_conditions_#{DateTime.now}.xls\""
        render "recent_as.xls.erb"
    	end
    end
    
  end

end
