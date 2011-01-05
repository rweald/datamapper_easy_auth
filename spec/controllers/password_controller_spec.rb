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
  
  
  describe "POST create" do
    context "the two password fields do not match" do
      it "should set the flash" do
        post :create, :new_password => "test", :new_password_confirmation  => " testrz"

        flash[:error].should == "The passwords did not match. Please try again."
      end
      
      it "should redirect back to the new view" do
        post :create, :new_password => "test", :new_password_confirmation  => " testrz"
        response.should redirect_to(:action => "new")    
      end
    end
    
    context "the two password fields match" do
      before do
        @myUser = Factory.build(:user)
        @myUser.save
      end
      it "should update the password in the db" do
        old_password = @myUser.hashed_password
        post :create, :new_password => "foo", :new_password_confirmation => "foo", :token => @myUser.password_change_token, :user_id => @myUser.id  
        User.get(1).hashed_password.should_not == old_password
      end
    end
  end
end
