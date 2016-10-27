require 'interswitch'

require 'test/unit'
require 'mocha/test_unit'
require 'json'
class InterswitchTest < Test::Unit::TestCase

  def test_init
    interswitch = Interswitch.new
    interswitch.init("IKIA9614B82064D632E9B6418DF358A6A4AEA84D7218", "XCTiBtLy1G9chAnyg0z3BcaFK4cVpwDg/GTw2EmjTZ8=")
    assert interswitch.client_token != nil
  end

  def test_send
    interswitch = Interswitch.new
    cert_path = "C:/paymentgateway.crt"
    pan = "6280511000000095"
    pin = "1111"
    expiry_date = "5004"
    cvv = "111"
    interswitch.init("IKIA9614B82064D632E9B6418DF358A6A4AEA84D7218", "XCTiBtLy1G9chAnyg0z3BcaFK4cVpwDg/GTw2EmjTZ8=")
    auth_data = interswitch.get_auth_data( cert_path, "1", pan, expiry_date, cvv, pin)
    data = {}
    data['customerId'] = "1407002510"
    data['amount'] = "200"
    data['transactionRef'] = "NMBDg12EVGH343"
    data['currency'] = "NGN"
    data['authData'] = auth_data

    uri = "https://sandbox.interswitchng.com/api/v2/purchases"
    response = interswitch.send(uri, 'POST', 'application/json', data, nil, http_headers={}, nil)
    puts JSON.parse(response)
  end

end