require 'openssl'
require 'base64'

module AuthData

  def AuthData.get_auth_data( public_cert, version, pan, exp_date, cvv, pin)
    auth_data = version + "Z" + pan + "Z" + pin + "Z" + exp_date + "Z" + cvv
    raw = File.read(public_cert_path)
    certificate = OpenSSL::X509::Certificate.new raw
    public_key = OpenSSL::PKey::RSA.new(File.read(certificate.public_key))
    encrypted_string = Base64.encode64(public_key.public_encrypt(auth_data))
    return encrypted_string
  end

end