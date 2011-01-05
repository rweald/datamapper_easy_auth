class PasswordController < ApplicationController
  def new
    # get the user from the id in the url
    @user_id = params[:user_id]
    @token_value = params[:token]
    current_user = User.get(@user_id)
    if current_user.password_change_token_valid? :token => @token_value
      render :action => "new"
    else
      flash[:error] = "Your password reset token has expired please request another one"
      render :action => "invalid_new"
    end
  end
  
  def create
    # catch the case where the two passwords do not match
    if params[:new_password] == params[:new_password_confirmation]
      # attempt to change the password
      if User.change_password!(:user_id => params[:user_id], :new_password => "test", :token => params[:token])
        return redirect_to("/")
      end
    else
      flash[:error] = "The passwords did not match. Please try again."
      redirect_to :action => "new"
    end
  end
end
