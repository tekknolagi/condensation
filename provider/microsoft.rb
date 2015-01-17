require 'net/http'
require 'rubygems'
require 'json'

class Provider ; end

class OnedriveService < Provider

  AUTH_URL = 'http://condensation-auth.herokuapps.com/onedrive'

  def self.get_token
    # Request authorization url from auth server
    response = Net::HTTP.get(URI("#{AUTH_URL}/build_url"))
    authorize_url = response['authorize_url']
    
    # Have the user sign in and authorize this app
    puts 'Please authorise Condensation for your Windows Live account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Login to your Live account and click "Allow"'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip

    # POST request to auth server to get client tokens
    response = Net::HTTP.post_form(URI("#{AUTH_URL}/api_token"), { 'code' => code })
    @access_token = response['access_token']
    @authentication_token = response['authentication_token']

    JSON.parse response # return parsed JSON object
  end

  def self.file_get

  end

  def self.file_put

  end

  def self.space_free

  end

end
