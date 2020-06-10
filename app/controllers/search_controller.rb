class SearchController < ApplicationController
  def embed
    response.headers.delete "X-Frame-Options" # Allow only this page to be available in an iframe.
    
    unless params[:group].nil?
      @category = Group.find_by(group_name: params[:group]) 
    end

    render 'embed', layout: 'embed'
  end
end