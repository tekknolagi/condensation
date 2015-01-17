require 'dropbox_sdk'
require 'net/http'
require 'rubygems'
require 'json'

module Dropbox
  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/dropbox/'

  def get_token
    # POST request to auth server to get authorization url
    authorize_url_json = Net::HTTP.post_form(URI.parse(AUTH_URL+'authorize'))
    parsed_json = JSON.parse(authorize_url_json)
    authorize_url = parsed_json['authorize_url']

    # Have the user sign in and authorize this app
    puts 'Please authorise Condensation for your Dropbox account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip

    # POST request to auth server to get client access token
    access_token_json = Net::HTTP.post_form(URI.parse(AUTH_URL+'api_token'), {'code' => code})
    parsed_json = JSON.parse(access_token_json)
    @@access_token = parsed_json['access_token']

    @@client = DropboxClient.new(@@access_token)
  end

  def file_get fn
    contents = @@client.get_file_and_metadata(File.join('/', fn))

    return contents # ignore metadata for now
  end

  def file_put file
    fn = File.basename(file.path) # get basename of file

    # Upload all files flat under apps dir root
    response = @@client.put_file(File.join('/', fn), file)

    # Good practice would be to inspect the response to make sure everything's ok
    return response
  end
  
  def space_free
  end
end
