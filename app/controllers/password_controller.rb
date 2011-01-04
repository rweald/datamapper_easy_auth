class PasswordController < ApplicationController
  def new
    # get the user from the id in the url
    current_user = User.get(params[:user_id])
    current_user.password_change_token_valid? :token => params[:token] 
  end
end
