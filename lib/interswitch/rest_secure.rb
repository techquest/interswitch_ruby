require 'securerandom'
require 'addressable/uri'
require 'open-uri'
require 'digest'
require 'base64'
require 'rack'

module RestSecure
  def generate_auth_headers(hash={})

    if !valid_params(hash)
      return nil
    end

    client_id = hash[:client_id]
    secret = hash[:secret]
    http_method = hash[:http_method]
    url = hash[:url]
    tran_parameters = hash[:tran_parameters]
    content_type = hash[:content_type]

    nonce = generate_nonce
    authorization = generate_authorization client_id
    timestamp = generate_timestamp
    signature = generate_signature(client_id, secret, url, http_method, timestamp, nonce, tran_parameters)

    headers = {
        "Signature" => signature,
        "Timestamp" => timestamp,
        "Nonce" => nonce,
        "Authorization" => authorization,
        "SignatureMethod" => "SHA1",
        "Content-Type" => content_type
    }

    return headers

  rescue => e
    puts "Error occured #{e.message}"
    return nil
  end

  def generate_signature(client_id, secret, url, http_method, timestamp, nonce, tran_parameters)

    url = url.sub("http://", "https://")
    encoded_url = Rack::Utils.escape(url).to_s
    puts encoded_url
    base_string = http_method + "&" +
        encoded_url + "&" +
        timestamp + "&" +
        nonce + "&" +
        client_id + "&" +
        secret

    temp_parameters = ""
    if tran_parameters && tran_parameters.kind_of?(Array) && tran_parameters.count > 0
      tran_parameters.each do |tran_parameter|
        temp_parameters = temp_parameters + "&" + tran_parameter.to_s
      end
    end

    full_string_to_be_signed = base_string + temp_parameters
    signature = Base64.encode64((Digest::SHA1.new() << full_string_to_be_signed).digest).strip

    return signature
  end

  def generate_authorization(client_id)
    "InterswitchAuth #{Base64.encode64(client_id)}"
  end


  def generate_timestamp
    Time.now.to_i.to_s
  end

  def generate_nonce
    SecureRandom.random_number(99999999999999999999999).to_s
  end


  def valid_params(hash={})

    if hash[:client_id].to_s.strip.length == 0
      puts ">>>Empty client id supplied.."
      return false
    end

    if hash[:secret].to_s.strip.length == 0
      puts ">>>Empty secret supplied.."
      return false
    end

    if hash[:http_method].to_s.strip.length == 0
      puts ">>>Empty http method supplied.."
      return false
    end

    if hash[:url].to_s.strip.length == 0
      puts ">>>Empty url supplied.."
      return false
    end

    return true

  end
end