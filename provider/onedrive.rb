require 'net/http'
require 'uri'
require 'json'
require 'launchy'

class Provider ; end

class OnedriveService < Provider
  AUTH_URL = 'http://condensation-auth.herokuapp.com/onedrive'
  attr_accessor :access_token

  def get_token
    # Request authorization url from auth server
    response = JSON.parse Net::HTTP.get(URI("#{AUTH_URL}/build_url"))
    authorize_url = response['authorize_url']

    # Have the user sign in and authorize this app
    Launchy.open(URI(authorize_url))
    puts 'Please authorise Condensation for your Windows Live account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Login to your Live account and click "Allow"'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip.gsub("\"","")

    # POST request to auth server to get client tokens
    response = Net::HTTP.post_form(URI("#{AUTH_URL}/api_token"), { 'code' => code })
    parsed_json = JSON.parse response.body
    @access_token = parsed_json['access_token']
    @authentication_token = parsed_json['authentication_token']

    parsed_json # return parsed JSON object
  end

  def file_get fn
    # Assumes fn is a basename

    # Retrieve onedrive file ID from db
    fid = json_file_data[fn][:id]

    # blob is a binary plaintext string of the file contents - this may need to be wrapped into some sort of object?
    Net::HTTP.get(URI("https://apis.live.net/v5.0/#{fid}/content"), { 'access_token' => @access_token })
  end

  def file_put file
    uri = URI("https://apis.live.net/v5.0/me/skydrive/files/#{File.basename file.path}")    
    uri.query = URI.encode_www_form({ :access_token => @access_token['access_token'], :downsize_photo_uploads => 'false' })
   

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
      request = Net::HTTP::Put.new uri
      request.body = file.read 
      request['Content-Type'] = "" # This NEEDS to be empty or MS complains

      response = https.request request
      parsed_json = JSON.parse response.body

      puts @access_token['access_token']
      puts response.body

      return parsed_json['id']
    end
  end

  def space_free
    uri = URI("https://apis.live.net/v5.0/me/skydrive/quota")
    uri.query = URI.encode_www_form({ :access_token => @access_token['access_token'] })

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
      request = Net::HTTP::Get.new uri
      response = https.request request
      quotas = JSON.parse response.body
      return quotas['available'].to_f() / (1024**2)
    end

    # response = Net::HTTP.get(URI("https://apis.live.net/v5.0/me/skydrive/quota").to_s, { 'access_token' => @access_token })
    #response['available'].to_f() / (1024**2) # Return available storage in megabytes

  end
end
