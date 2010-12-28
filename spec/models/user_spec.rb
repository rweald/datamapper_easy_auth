require 'spec_helper'

describe User do
  before(:each) do
    @new_user = User.new :email => "test@test.com", :password => "test"
  end
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
end
