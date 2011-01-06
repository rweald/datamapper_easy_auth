require 'spec_helper'
require "ruby-debug"
describe Session do
  before(:each) do
    @sesh = Session.new
    @user = Factory(:user)
    @sesh.user = @user
  end
  
  context "validation" do  
    it "should validate presence of user_id" do
      @sesh.user = nil
      @sesh.save().should be_false
      
      @sesh.user = @user
      @sesh.save().should be_true
    end
    
    it "should validate presence of expiration" do
      @sesh.expiration = nil
      @sesh.valid?().should be_false      
    end
  end
  
  
end
