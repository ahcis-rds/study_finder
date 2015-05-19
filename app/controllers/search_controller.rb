class SearchController < ApplicationController
  def embed
    unless params[:group].nil?
      response.headers.delete "X-Frame-Options" # Allow only this page to be available in an iframe.
      @category = StudyFinder::Group.find_by(group_name: params[:group]) 
    end

    render 'embed', layout: 'embed'
  end
end