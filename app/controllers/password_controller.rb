class PasswordController < ApplicationController
  def new
    # get the user from the id in the url
    current_user = User.get(params[:user_id])
    if current_user.password_change_token_valid? :token => params[:token] 
      render :action => "new"
    else
      flash[:error] = "Your password reset token has expired please request another one"
      render :action => "invalid_new"
    end
  end
end
