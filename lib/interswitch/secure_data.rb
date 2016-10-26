require 'openssl'
require 'base64'
module SecureData


  def SecureData.getSecureData( public_cert_path, pan, exp_date)

  end

  def generateKey
    triple_des = OpenSSL::Cipher::Cipher.new('des-ede3')
    triple_des.encrypt
    return triple_des.random_key
  end

end