require "interswitch/version"
require "interswitch/secure_data"
require "interswitch/rest_secure"
require "interswitch/auth_data"
require 'oauth2'
require 'rest-client'

class Interswitch
  include SecureData
  include AuthData
  include RestSecure

  @client_token = nil
  @client_id = nil
  @secret_key = nil
  @client = nil
  @environment = nil
  @token_url = nil

  def init(client_id, secret_key, environment = "SANDBOX")
    @client_id = client_id
    @secret_key = secret_key
    @environment = environment
    if environment == "SANDBOX"
      @token_url = InterswitchVersion::SANDBOX_URL
    else
      @token_url = InterswitchVersion::PROD_URL
    end

    @client = OAuth2::Client.new(@client_id, @secret_key, :site => @token_url, :token_url => "/passport/oauth/token")
    oauth_response = @client.client_credentials.get_token
    @client_token = oauth_response.token

  end

  def send(uri, http_method, content_type, data, access_token, http_headers={}, signed_parameters = nil)
    auth_headers = generate_auth_headers(:client_id => @client_id, :secret => @secret_key,
                                         :http_method => http_method,
                                         :url => uri, :content_type => content_type)
    if access_token == nil || access_token.length == 0
      access_token = @client_token
    end

    auth_headers['Authorization'] = "Bearer #{access_token}"
    if !http_headers.empty?
      http_headers.each { |key, value|
        auth_headers[key] = value
      }
    end

    payload = content_type == 'json' ? data.to_json : data.to_xml

    response = nil
    begin
      if (http_method.casecmp("post"))
        response = RestClient::Request.execute(:url => uri, :method => :post, :payload => payload, :headers => auth_headers, :ssl_version => 'TLSv1_2')
      elsif (http_method.casecmp("put"))
        response = RestClient::Request.execute(:url => uri, :method => :put, :payload => payload, :headers => auth_headers, :ssl_version => 'TLSv1_2')
      else
        response = RestClient.get(uri, data, :headers => auth_headers)
      end
    rescue => e
      response = e.response
      puts response
    end

    return response

  end

  def get_client_token
    @client_token
  end

  def get_password_token(username, password)
    oauth_response = @client.password.get_token(username, password)
    oauth_response.token
  end


end

