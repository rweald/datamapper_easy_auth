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
        @new_user.save
        hash_value = @new_user.hashed_password
        
        @new_user.stubs(:password_changed?).returns(true)
        @new_user.password = "blah"
        @new_user.save
        @new_user.hashed_password.should_not == hash_value
      end
    end
  end
end
