require 'net/http'
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
    # downsize_photo_uploads prevents OneDrive from resizing images
    response = Net::HTTP.put(URI("https://apis.live.net/v5.0/me/skydrive/files#{file.basename}"),
      { 'access_token' => @access_token, 'downsize_photo_uploads' => 'false' },
      file.read)

    # Associate filename with its onedrive id
    json_file_data[file.basename][:id] = response['id']

    response['id']
  end

  def space_free
    uri = URI("https://apis.live.net/v5.0/me/skydrive/quota")
    uri.query = URI.encode_www_form({ :access_token => @access_token })

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
      request = Net::HTTP::Get.new uri
      response = https.request request
      puts JSON.parse response.body
    end

    # response = Net::HTTP.get(URI("https://apis.live.net/v5.0/me/skydrive/quota").to_s, { 'access_token' => @access_token })
    # response['available'].to_f() / (1024**2) # Return available storage in megabytes
  end
end
