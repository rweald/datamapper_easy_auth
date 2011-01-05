Factory.define :user, :class => User do |f|
  f.email "test@test.com"
  f.password "test"
  f.password_change_token "abcd"
  f.token_expiration (DateTime.now() + 1)
end