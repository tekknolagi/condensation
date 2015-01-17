require 'dropbox_sdk'
require 'net/http'
require 'rubygems'
require 'json'

class Provider; end

class DropboxService < Provider
  AUTH_URL = 'http://condensation-auth.herokuapp.com/dropbox'

  def self.get_token
    # POST request to auth server to get authorization url
    authorize_url_json = Net::HTTP.post_form(URI("#{AUTH_URL}/authorize"), {})
    parsed_json = JSON.parse(authorize_url_json.body)
    authorize_url = parsed_json['authorize_url']

    # Have the user sign in and authorize this app
    puts 'Please authorise Condensation for your Dropbox account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip

    # POST request to auth server to get client access token
    access_token_json = Net::HTTP.post_form(URI("#{AUTH_URL}/api_token"), { 'code' => code })
    parsed_json = JSON.parse(access_token_json.body)
    @@access_token = parsed_json['access_token']
    @@client = DropboxClient.new(@@access_token)

    @@access_token
  end

  def self.file_get fn
    # ignore metadata for now
    @@client.get_file_and_metadata(File.join('/', fn))
  end

  def self.file_put file
    fn = File.basename(file.path) # get basename of file

    # Upload all files flat under apps dir root
    # Good practice would be to inspect the response to make sure everything's ok
    @@client.put_file(File.join('/', fn), file)
  end

  def self.space_free
    account_json = @@client.account_info()
    account_parsed = JSON.parse(account_json)
    quota_info = account_parsed['quota_info']

    # Assuming this adds up to total storage used by the user
    used_storage = quota_info['normal'].to_i() + quota_info['shared'].to_i() 
    
    bytes_free = quota_info['quota'].to_i() - used_storage 

    bytes_free / 1048576.0 # return megabytes free (1024*1024)
  end
end
