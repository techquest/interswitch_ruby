require 'interswitch'

require 'test/unit'
require 'mocha/test_unit'
require 'json'
class InterswitchTest < Test::Unit::TestCase

  def test_init
    interswitch = Interswitch.new
    interswitch.init("IKIA9614B82064D632E9B6418DF358A6A4AEA84D7218", "XCTiBtLy1G9chAnyg0z3BcaFK4cVpwDg/GTw2EmjTZ8=")
    assert interswitch.get_client_token != nil
  end

end