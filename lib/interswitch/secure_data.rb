require 'openssl'
require 'base64'
module SecureData


  def SecureData.get_secure_data(public_cert_path, pan, exp_date, cvv, pin, *transaction_parameters)

    pin_des_key = self.hex_to_bin(self.generate_key)
    mac_des_key = ""
    header_bytes = self.hex_to_bin("4D")
    format_version_bytes = self.hex_to_bin("10")
    mac_version_bytes = self.hex_to_bin("10")
    key_bytes = generate_key

    if pan.to_s.strip.length != 0
      pan.ljust(20, 'F')
    end
    customer_id_bytes = self.hex_to_bin(pan)
    mac_data = self.get_mac_data_version_9(transaction_parameters)
    mac_bytes = hex_to_bin(get_mac(mac_data, mac_des_key, 11))
    footer_bytes = hex_to_bin("5A")
    other_bytes = Array.new(14, 0).join

    secure_bytes = header_bytes + format_version_bytes + mac_version_bytes +
        pin_des_key + mac_des_key + customer_id_bytes + mac_bytes + other_bytes + footer_bytes


    raw = File.read(public_cert_path)
    certificate = OpenSSL::X509::Certificate.new raw
    public_key = OpenSSL::PKey::RSA.new(certificate.public_key)
    encrypted_secure = bin_to_hex(public_key.public_encrypt(secure_bytes))
    pin_block = get_pin_block(pin, cvv, exp_date, key_bytes)

    secure_data = {}
    secure_data[:secure] = encrypted_secure
    secure_data[:pin_block] = pin_block
    return secure_data

  end

  def SecureData.generate_key
    triple_des = OpenSSL::Cipher::Cipher.new('des-ede')
    triple_des.encrypt
    return triple_des.random_key
  end

  def SecureData.bin_to_hex(string)
    string.each_byte.map { |b| b.to_s(16) }.join
  end

  def SecureData.hex_to_bin(string)
    string.scan(/../).map { |x| x.hex.chr }.join
  end

  def SecureData.get_mac (mac_data, mac_key, mac_version)
    mac_cipher = ""
    if mac_version.to_i == 8
      cipher = OpenSSL::Cipher::Cipher.new('AES-128-CBC-HMAC-SHA1')
      cipher.encrypt
      mac_key = cipher.random_key
      mac_cipher = cipher.update(mac_data) + cipher.final
    elsif mac_version.to_i == 12
      cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC-HMAC-SHA1')
      cipher.encrypt
      mac_key = cipher.random_key
      mac_cipher = cipher.update(mac_data) + cipher.final
    else
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE-CBC')
      cipher.encrypt
      mac_key = cipher.random_key
      mac_cipher = cipher.update(mac_data) + cipher.final
    end

    return mac_cipher
  end


  def SecureData.get_mac_data_version_9(*transaction_parameters)
    mac_data = Array.new(1, 0).join

    # if (transaction_parameters.length > 0 && transaction_parameters.is_a?(Array))
    #   transaction_parameters.each { |parameter|
    #     puts parameter
    #     mac_data += parameter
    #   }
    # end
    return mac_data
  end

  def SecureData.get_pin_block(pin, cvv2, expiry_date, key_bytes)
    pin_new = pin == nil || pin.length == 0 ? "0000" : pin
    cvv2_new = cvv2 == nil || cvv2.length == 0 ? "000" : cvv2
    expiry_date_new = expiry_date == nil || expiry_date.length == 0 ? "0000" : expiry_date
    pin_block_string = pin_new + cvv2_new + expiry_date_new
    pin_block_string_length = pin_block_string.length
    pin_block_string_length_length = pin_block_string_length.to_s.length
    clear_pin_block = pin_block_string_length_length.to_s + pin_block_string_length.to_s + pin_block_string
    random_digit = rand(10**2)
    pin_pad_length = 16 - clear_pin_block.length

    for i in 0..pin_pad_length
      clear_pin_block = clear_pin_block + random_digit.to_s
    end

    des_ede = OpenSSL::Cipher::Cipher.new('des-ede')
    des_ede.iv = key_bytes
    des_ede.encrypt
    encrypted_pin_block = des_ede.update(clear_pin_block) + des_ede.final
    return bin_to_hex(encrypted_pin_block)

  end

end