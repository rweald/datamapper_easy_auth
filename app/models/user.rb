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
  
  # sets up the association to session object.
  has n, :sessions

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

  # method that can be used to determine if a password reset token is valid
  # based on the token value stored in the db and also checks to ensure
  # that the token has not expired.
  def password_change_token_valid?(args)
    # basic sanity check to ensure user has a reset token
    if self.password_change_token
      if (self.password_change_token == args[:token]) && self.token_expiration > DateTime.now
        return true
      end
    end
    return false
  end
  
  # class method that will generate a password change token
  # for the current user and return it. The token will also
  #  be stored in the db so you can verify the token at a later time
  # Requires the email address of the user who wants to change password
  # if the email address if not valid then nil will be returned.
  def self.generate_password_change_token(email=nil)
    current_user = User.first(:email => email)
    if current_user
      token = Digest::SHA1.hexdigest(current_user.hashed_password + DateTime.now().to_i().to_s + current_user.id.to_s)
      current_user.password_change_token = token
      current_user.token_expiration = DateTime.now() + 1
      current_user.save
      return token
    else
      return nil
    end
  end

  # Method that performs the change of password if the supplied 
  # token is correct for the user who's email address is supplied. 
  # This is a desructive method and will change the users password forever
  # Requires an email address, token, and new password
  # will return the logic result of the operation
  def self.change_password!(args)
    # get the user from the email address
    current_user = User.get(args[:user_id])
    if current_user
      # check to ensure that the tokens match
      if current_user.password_change_token_valid?(:token => args[:token])
        current_user.password = args[:new_password]
        current_user.secure_password
        return current_user.save
      else
        return false
      end
    else
      return false
    end
  end

  # class method that can perform authentication based on email and password
  # will return the user object if the authentication is successful and nil
  # if the auth is not successful.
  def self.authenticate(args)
    attempted_user = User.first(:email => args[:email])
    if attempted_user
      attempted_password_hash = attempted_user.generate_hash("#{args[:password]}" + "#{attempted_user.salt}")
      if attempted_password_hash == attempted_user.hashed_password
        return attempted_user
      end
    end
    return nil
  end
end
