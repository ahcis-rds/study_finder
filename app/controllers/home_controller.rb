class HomeController < ApplicationController
  def index
    @featured_category = Group.find_by(group_name: 'COVID-19')
    
    #TODO - This should be optimized for studyfinder 2.0
    @cancer_category = Group.find_by(group_name: 'Cancer')
    @diabetes_category = Group.find_by(group_name: 'Diabetes & Hormone')
    @prevention_category = Group.find_by(group_name: 'Prevention')
    @womens_health_category = Group.find_by(group_name: "Women's Health")
  	@showcase = ShowcaseItem.where(active: true).order(:sort_order)
  end

  def splash
    render layout: 'splash'
  end

  def spotlight
  end
end
