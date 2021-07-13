class HomeController < ApplicationController
  def index
    @showcase = ShowcaseItem.where(active: true).order(:sort_order)
  end

  def splash
    render layout: 'splash'
  end

  def spotlight
  end
end
