require "interswitch/secure_data"

class SecureDataTest < Test::Unit::TestCase
  include SecureData
  def test_get_secure_data
    cert_path = "C:/paymentgateway.crt"
    pan = "6280511000000095"
    pin = "1111"
    expiry_date = "5004"
    cvv = "111"
    secure_data = get_secure_data(cert_path, pan, expiry_date, cvv, pin, 'msisdn' => "1234")
    assert secure_data != nil
  end
end