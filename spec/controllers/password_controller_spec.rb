require 'spec_helper'

describe PasswordController do
  describe "GET new" do
    # set up the user and create the password reset token
    before(:each) do
      @myUser = mock()
      User.stubs(:get).returns(@myUser)
    end
  
    context "token is invalid" do
      before do
        @myUser.expects(:password_change_token_valid?).returns(false)
      end  
      it "should set flash[:error]" do
        get :new, :token => "bad value", :user_id  => 1 
        flash[:error].should_not be_nil
      end
      
      it "should render error page" do
        get :new, :token => "bad value", :user_id  => 1 
        response.should render_template("invalid_new")
      end
    end
      
    context "token is valid" do
      before do
        @myUser.expects(:password_change_token_valid?).returns(true)
      end
      it "should not set the flash" do
        get :new, :token => "bad value", :user_id  => 1 
        flash[:error].should be_nil
      end
      it "should render the view" do
        get :new, :token => "bad value", :user_id  => 1 
        response.should render_template("new")
      end
    end
  end
end
