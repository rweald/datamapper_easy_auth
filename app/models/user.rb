class User
  include DataMapper::Resource

  # instance variable to hold unhashed password temporarily
  attr_accessor :password

  # The basic properties
  property :id, Serial
  property :email, String, :required => true, :format => :email_address
  property :salt, String
  property :hashed_password, String

  # properties for email verification
  property :verified, Boolean, :default => false
  property :verification_token, String, :required => true

  # properties for password reset
  property :password_change_token , String
  property :token_expiration, DateTime


  # hooks to add values and perform necessary operations before insert to db
  before :valid?, :create_verification_token

  # Method that will create a verification token that
  # can be emailed out to ensure a valid email address
  def create_verification_token
    string = "#{DateTime.now().to_i()}" + self.id.to_s() + self.salt.to_s()
    self.verification_token = generate_hash(string)
  end

  # Method that will generate a hash
  def generate_hash(string)
    Digest::SHA1.hexdigest(string)
  end
end
