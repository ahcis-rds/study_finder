class HomeController < ApplicationController
  def index
    @featured_category = Group.find_by(group_name: 'COVID-19')
    @showcase = ShowcaseItem.where(active: true).order(:sort_order)
  end

  def splash
    render layout: 'splash'
  end

  def spotlight
  end
end
