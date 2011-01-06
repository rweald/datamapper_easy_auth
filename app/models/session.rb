class Session

  include DataMapper::Resource

  property :id, Serial
  property :expiration, DateTime, :required => true
  property :keep_logged_in, Boolean, :default => false
  property :user_id, Integer, :key => true, :min => 1# , :required => true
  
  # assication decleration
  belongs_to :user

  before :valid?, :set_expiration
  
  # sets up the expiration date for the token. Will set the date 2 weeks
  # in advance if the user wants to be kept loggedin. Otherwise it is 
  # set to 20 mins from now
  def set_expiration
    if self.keep_logged_in
      self.expiration = DateTime.now + 14
    else
      self.expiration = DateTime.now + 0.02
    end
  end
  
end
