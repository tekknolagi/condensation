require 'net/http'
require 'rubygems'
require 'json'

class Provider ; end

class OnedriveService < Provider

  AUTH_URL = 'http://condensation-auth.herokuapps.com/onedrive'
  attr_accessor :access_token

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

  def self.file_get fn

  end

  def self.file_put file
    response = Net::HTTP.put(URI("https://apis.live.net/v5.0/me/skydrive/files"+file.basename), 
                            { 'access_token' => @access_token }, 
                            file.read)    

    # Associate filename with its onedrive id
    json_file_data[file.basename][:id] = response['id']

    return response['id']
  end

  def self.space_free
    response = Net::HTTP.get(URI("https://apis.live.net/v5.0/me/skydrive/quota"), {'access_token' => @access_token})

    response['available'].to_f() / (1024**2) # Return available storage in megabytes
  end

end
