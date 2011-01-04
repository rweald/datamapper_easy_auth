require 'spec_helper'

describe PasswordController do
  describe "GET new" do
    context "token is invalid" do
            
      it "should set flash[:error]" do
        flash[:error].should_not be_nil
        get :new, :token => "bad value", :email => "test@test.com" 
      end
      
      it "should redirect to error page" do
        get :new, :token => "bad value", :email => "test@test.com" 
        response.should redirect_to(:controller => "password", :action => "bad_token")
      end
    end
      
    context "token is valid" do
      it "should not set the flash" do
        get :new
        flash[:error].should be_nil
      end
      it "should render the view" do
        get :new
        response.should be_success
      end
    end
  end
end
