require "interswitch/secure_data"

class SecureDataTest < Test::Unit::TestCase

  def test_get_secure_data
    cert_path = "C:/paymentgateway.crt"
    pan = "6280511000000095"
    pin = "1111"
    expiry_date = "5004"
    cvv = "111"
    secure_data = SecureData::get_secure_data(cert_path, pan, expiry_date, cvv, pin, {})
    puts secure_data
  end
end