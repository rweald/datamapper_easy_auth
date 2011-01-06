require 'spec_helper'
require "ruby-debug"

describe User do
  before(:each) do
    @myUser = Factory(:user)
    @myUser.save
  end

  context "attribute validation" do
    # override the usual before method because we dont want a pre-saved
    # copy because this is validation
    before do
      @myUser = User.new :email => "test@test.com", :password => "test"
    end
    
    it "should validate presence of email" do
      @myUser.email = "test@test.com"
      @myUser.save.should_not == false

      @myUser.email = nil
      @myUser.save.should_not == true

    end

    it "should generate salt upon save" do
      @myUser.save
      @myUser.salt.should_not be_nil
    end

    it "should hash the password upon save" do
      @myUser.save
      @myUser.hashed_password.should_not be_nil
    end

    it "should validate presence of password" do
      @myUser.password = nil
      @myUser.save.should == false
    end
  end

  describe "#secure_password" do
    context "user does not have a password stored yet" do
      it "should hash the password" do
        @myUser.save
        @myUser.hashed_password.should_not be_nil
      end
      
      it "should only hash a password once" do
        @myUser.save 
        hash_value = @myUser.hashed_password
        @myUser.password = 'blah'
        @myUser.save
        @myUser.hashed_password.should == hash_value
      end
    end
    
  end
  
  describe "#generate_password_change_token" do
    
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
    
    context "the tokens match" do
      it "should change the users password in the db" do
        old_value = @myUser.hashed_password
        User.change_password!(:token => @myUser.password_change_token, :user_id=> @myUser.id, :new_password => "foobar").should be_true
        User.first(:email => @myUser.email).hashed_password.should_not == old_value
      end
    end
    
    context "the tokens do not match" do
      it "should return false" do
        User.change_password!(:token => "bad token value", :user_id => @myUser.id, :new_password => "foobar").should_not be_true
      end
    end
  end
  
  describe "#self.authenticate" do
    context "values are correct" do
      it "should return user object" do
        User.authenticate(:email => "test@test.com",:password => "test").should_not be_nil
      end
    end
    
    context "values are incorrect" do
      it "should return nil" do
        User.authenticate(:email => "test@test.com",:password => "bad password").should be_nil
      end
    end
  end
end
