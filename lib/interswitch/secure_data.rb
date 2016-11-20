require 'openssl'
require 'base64'
module SecureData


  def get_secure_data(public_cert_path, pan, exp_date, cvv, pin, transaction_parameters = {})

    pin_des_key = generate_key()
    mac_des_key = generate_key()
    header_bytes = "4D"

    format_version_bytes = "10"
    mac_version_bytes = "10"
    pan_diff = 20 - pan.length
    pan = pan_diff.to_s + pan

    if pan.to_s.strip.length != 0
      pan = pan.ljust(20, 'F')
    end
    customer_id_bytes = pan
    mac_data = self.get_mac_data_version_9(transaction_parameters)
    mac_bytes = hex_to_bin(get_mac(mac_data, mac_des_key, 11))[0..7]


    footer_bytes = "5A"
    other_bytes = "0000000000000000000000000000"
    secure_bytes = header_bytes + format_version_bytes + mac_version_bytes +
        pin_des_key.unpack('H*').first + mac_des_key.unpack('H*').first + customer_id_bytes + mac_bytes +other_bytes + footer_bytes

    secure_bytes = secure_bytes.ljust(512, '0')
    raw = File.read(public_cert_path)
    certificate = OpenSSL::X509::Certificate.new raw
    public_key = OpenSSL::PKey::RSA.new(certificate.public_key)
    encrypted_secure = public_key.public_encrypt([secure_bytes].pack('H*'), 3).unpack('H*')

    pin_block = get_pin_block(pin, cvv, exp_date, pin_des_key)
    secure_data = {}
    secure_data[:secure] = encrypted_secure
    secure_data[:pin_block] = pin_block
    return secure_data

  end

  def generate_key
    triple_des = OpenSSL::Cipher::Cipher.new('des-ede-cbc')
    triple_des.encrypt
    random_key = triple_des.random_key
    return random_key
  end


  def bin_to_hex(string)
    string.each_byte.map { |b| b.to_s(16) }.join
  end

  def hex_to_bin(string)
    string.scan(/../).map { |x| x.hex }.join
  end

  def get_mac (mac_data, mac_key, mac_version)
    mac_cipher = ""
    if mac_version.to_i == 8
      cipher = OpenSSL::Cipher::Cipher.new('AES-128-CBC-HMAC-SHA1')
      cipher.encrypt
      cipher.key = mac_key
      mac_cipher = cipher.update([mac_data].pack('H*')) + cipher.final
    elsif mac_version.to_i == 12
      cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC-HMAC-SHA1')
      cipher.encrypt
      cipher.key = mac_key
      mac_cipher = cipher.update([mac_data].pack('H*')) + cipher.final
    else
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE-CBC')
      cipher.encrypt
      cipher.key = mac_key
      mac_cipher = cipher.update([mac_data].pack('H*')) + cipher.final
    end
    return mac_cipher.unpack('H*').first
  end


  def get_mac_data_version_9(transaction_parameters)
    mac_data = ""
    if transaction_parameters["tid"] != nil
      mac_data += transaction_parameters["tid"].to_s
    end

    if transaction_parameters['msisdn'] != nil
      mac_data += transaction_parameters['msisdn'].to_s
    end

    if transaction_parameters["cardName"] != nil
      mac_data += transaction_parameters["cardName"].to_s
    end

    if transaction_parameters["ttid"] != nil
      mac_data += transaction_parameters["ttid"].to_s
    end

    if transaction_parameters["amt"] != nil
      mac_data += transaction_parameters["amt"].to_s
    end

    if transaction_parameters["toAcctNo"] != nil
      mac_data += transaction_parameters["toAcctNo"].to_s
    end

    if transaction_parameters["toBankCode"] != nil
      mac_data = transaction_parameters["toBankCode"].to_s
    end

    if transaction_parameters["toBankCode"] != nil
      mac_data = transaction_parameters["toBankCode"].to_s
    end


    return mac_data
  end

  def get_pin_block(pin, cvv2, expiry_date, key_bytes)
    pin_new = pin == nil || pin.length == 0 ? "0000" : pin
    cvv2_new = cvv2 == nil || cvv2.length == 0 ? "000" : cvv2
    expiry_date_new = expiry_date == nil || expiry_date.length == 0 ? "0000" : expiry_date

    pin_block_string = pin_new + cvv2_new + expiry_date_new

    pin_block_string_length = pin_block_string.length.to_s
    pin_block_string_length_length = pin_block_string_length.length
    clear_pin_block = pin_block_string_length_length.to_s + pin_block_string_length.to_s + pin_block_string

    random_digit = 0
    pin_pad_length = 16 - clear_pin_block.length

    for i in 1..pin_pad_length

      clear_pin_block = clear_pin_block + random_digit.to_s
    end


    des_ede = OpenSSL::Cipher::Cipher.new('des-ede-cbc')
    des_ede.key = key_bytes
    des_ede.encrypt
    encrypted_pin_block = des_ede.update([clear_pin_block].pack('H*')) + des_ede.final
    pin_block_hex = encrypted_pin_block.unpack('H*')

    return pin_block_hex

  end

end