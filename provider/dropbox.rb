require 'dropbox_sdk'
require 'net/http'
require 'json'
require 'launchy'

class Provider; end

class DropboxService < Provider
  AUTH_URL = 'http://condensation-auth.herokuapp.com/dropbox'
  attr_accessor :access_token

  def get_token
    # POST request to auth server to get authorization url
    authorize_url_json = Net::HTTP.post_form(URI("#{AUTH_URL}/authorize"), {})
    parsed_json = JSON.parse(authorize_url_json.body)
    authorize_url = parsed_json['authorize_url']

    Launchy.open(URI(authorize_url))
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
    @access_token = parsed_json['access_token']

    @access_token
  end

  def file_get (fn, fid)
    # ignore metadata for now
    client = DropboxClient.new @access_token
    contents, metadata = client.get_file_and_metadata File.join('/', fn)
    return contents # return a binary plaintext string of the file contents
  end

  def file_put file
    fn = File.basename file.path

    # Upload all files flat under apps dir root
    # Good practice would be to inspect the response to make sure everything's ok
    client = DropboxClient.new @access_token
    client.put_file File.join('/', fn), file
    return '' # fid is empty string for dropbox - no fid
  end

  def file_del (fn, fid) # fid is ignored
    client = DropboxClient.new @access_token
    client.file_delete File.join('/', fn)
  end

  def space_free
    bytes_free = -1
    begin
      client = DropboxClient.new @access_token
      account_parsed = client.account_info
      quota_info = account_parsed['quota_info']

      # Assuming this adds up to total storage used by the user
      used_storage = quota_info['normal'].to_i + quota_info['shared'].to_i
      bytes_free = quota_info['quota'].to_i - used_storage
    rescue Exception # usually happens when access_token isn't valid, we return -1
      puts "Dropbox access token invalid!"
    end
    
    bytes_free / 1048576.0 # return megabytes free (1024*1024)
  end
end
