class FrontController < ApplicationController
  def index
    if params[:u]
      @shorturl = Shorturl.find_by_target_url(params[:u])
    else
      @shorturl = Shorturl.new
    end
  end

end
