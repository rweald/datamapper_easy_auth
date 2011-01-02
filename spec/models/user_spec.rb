require 'spec_helper'
require "ruby-debug"

describe User do
  before(:each) do
    @new_user = User.new :email => "test@test.com", :password => "test"
  end

  context "attribute validation" do
    it "should validate presence of email" do
      @new_user.email = "test@test.com"
      @new_user.save.should_not == false

      @new_user.email = nil
      @new_user.save.should_not == true

    end

    it "should generate salt upon save" do
      @new_user.save
      @new_user.salt.should_not be_nil
    end

    it "should hash the password upon save" do
      @new_user.save
      @new_user.hashed_password.should_not be_nil
    end

    it "should validate presence of password" do
      @new_user.password = nil
      @new_user.save.should == false
    end
  end

  describe "#secure_password" do
    context "user does not have a password stored yet" do
      it "should hash the password" do
        @new_user.save
        @new_user.hashed_password.should_not be_nil
      end
      
      it "should only hash a password once" do
        @new_user.save 
        hash_value = @new_user.hashed_password
        @new_user.password = 'blah'
        @new_user.save
        @new_user.hashed_password.should == hash_value
      end
    end
    
    context "users password has changed" do
      it "should re-hash the password" do
        pending
      end
    end
  end
  
  describe "#generate_password_change_token" do
    before(:each) do
      @myUser = User.create(:email => "test@test.com", :password => "test")
    end
    
    context "email address is in the db" do
      # it "simple test" do
      #   myUser = User.first(:email => "test@test.com")
      #   myUser.email.should == "test@test.com"
      # end
      it "should return a hashed token string" do
        return_value = User.generate_password_change_token("test@test.com") 
        return_value.should_not be_nil
      end
    end
    
    context "the email address is not in the db" do
      it "should return nil" do
        returned_value = User.generate_password_change_token :email => "not@indb.com"  
        returned_value.should be_nil
      end
    end
  end
  
  describe "change_password!" do
    before(:each) do
      @myUser = User.create :email => "test@test.com", :password => "test"
      User.generate_password_change_token("test@test.com")
    end
    
    context "the tokens match" do
      it "should change the users password in the db" do
        old_value = @myUser.hashed_password
        User.change_password!(:token => @myUser.password_change_token, :email => @myUser.email, :new_password => "foobar").should be_true
        User.first(:email => @myUser.email).hashed_password.should_not == old_value
      end
    end
  end
end
