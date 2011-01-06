class SessionController < ApplicationController
  respond_to :html
  
  # simply renders the new view
  def new
    render :action => "new"
  end
  
  def create
    
  end
end
