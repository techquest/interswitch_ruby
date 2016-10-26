require "interswitch/version"
require "interswitch/secure_data"
require "interswitch/auth_data"

class Interswitch
  include SecureData
  include AuthData
end
