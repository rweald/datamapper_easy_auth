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
  before :create, :secure_password

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

  # called before the object is saved to the db. Will
  # take the password instance variable and salt and hash it
  # before storing it in the db.
  # should be completed if the password has not changed
  def secure_password
    validate_password!
    self.salt = ActiveSupport::SecureRandom.base64(8)
    self.hashed_password = generate_hash("#{self.password}" + "#{self.salt}")
  end

  # custom validation method to ensure that password
  # instance variable has a value.
  def validate_password!
    if self.password == nil
      throw :halt
    end
  end

  # check to see if the password has changed or
  # there is no hashed_password so we need to call
  # the secure_password method.
  def password_changed?
    if !self.hashed_password
      return true
    else
      if password_reset_valid?
        return true
      else
        return false
      end
    end
  end

  def password_reset_valid?
    if self.password_change_token
      # check to see if the token has not expired
      if self.token_expiration < DateTime.now
        return true
      else
        return false
      end
    end
    return false
  end
end
