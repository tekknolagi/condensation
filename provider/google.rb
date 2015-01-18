require 'json'
require 'launchy'
require 'google/api_client'

require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'


class Provider; end

class GoogleService < Provider

  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/google'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

  API_VERSION = 'v2'
  CACHED_API_FILE = "drive-#{API_VERSION}.cache"
  CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"

  @client

  attr_accessor :access_token

  # There are some issues with trying to split this up into a proper client-server for client auth
  # See this: https://developers.google.com/drive/web/quickstart/quickstart-ruby
  def get_token
    puts "1"
    log_file = File.open('drive.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG
    puts "2"
    create_client

    # FileStorage stores auth credentials in a file, so they survive multiple runs
    # of the application. This avoids prompting the user for authorization every
    # time the access token expires, by remembering the refresh token.
    # Note: FileStorage is not suitable for multi-user applications.
    file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
    if file_storage.authorization.nil?
        puts "3"
      # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
      # application flow, which ties in with FileStorage to store credentials
      # between runs.
      flow = Google::APIClient::InstalledAppFlow.new(
        :client_id => @client.authorization.client_id,
        :client_secret => @client.authorization.client_secret,
        :scope => ['https://www.googleapis.com/auth/drive']
      )
      @client.authorization = flow.authorize(file_storage)
    else
      @client.authorization = file_storage.authorization
    end
  puts "4"
    drive = nil
    # Load cached discovered API, if it exists. This prevents retrieving the
    # discovery document on every run, saving a round-trip to API servers.
    if File.exists? CACHED_API_FILE
      File.open(CACHED_API_FILE) do |file|
        drive = Marshal.load(file)
          puts "5"
      end
    else
      drive = @client.discovered_api('drive', API_VERSION)
      File.open(CACHED_API_FILE, 'w') do |file|
        Marshal.dump(drive, file)
          puts "6"
      end
    end
      puts "7"
    return client, drive
  end 

  def create_client
      puts "2.1"

    # Create a new API client & load the Google Drive API
    @client = Google::APIClient.new({ :application_name => 'Condensation', :application_version => '0.0.0' })
    @drive = @client.discovered_api('drive', 'v2')
    puts "2.2"
    # POST request to auth server to get JSON of api keys
    secrets = Net::HTTP.get(URI.parse("#{AUTH_SERVER}/secrets"))
    api_secrets = JSON.parse(secrets)
    client_id = api_secrets['key']
    client_secret = api_secrets['secret']
      puts "2.3"
    # Request authorization
    @client.authorization.client_id = client_id
    @client.authorization.client_secret = client_secret
    @client.authorization.scope = OAUTH_SCOPE
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.access_token = @access_token if @access_token
    puts "2.4"
  end
end
#   def file_get fn
#     create_client
#     file_properties = json_file_data[fn]
#     google_id = file_properties["id"]

#     #starts callback flow
#     result = @client.execute(
#       :api_method => @drive.files.get,
#       :parameters => { 'fileId' => file_id })
#     if result.status == 200
#       file = result.data
#       if file.download_url
#         result = @client.execute(:uri => file.download_url)
#         if result.status == 200
#           return result.body
#         else
#           puts "There was an error downloading the file from drive"
#           return false
#         end
#       else
#         puts "Error: File did not have downloadable content"
#         return false
#       end
#     else
#       puts "There was an error getting file from fileId, check file name again"
#       return false
#     end
#   end

#   def file_put file
#     create_client
#     drive = @client.discovered_api('drive', 'v2')
#     file = drive.files.insert.request_schema.new({
#       #metadata for later
#     })

#     # Set the parent folder.
#     if parent_id
#       file.parents = [{'id' => parent_id}]
#     end
#     media = Google::APIClient::UploadIO.new(file_name, "application/octet-stream")
#     result = @client.execute(
#       :api_method => drive.files.insert,
#       :body_object => file,
#       :media => media,
#       :parameters => {
#         'uploadType' => 'multipart',
#         'alt' => 'json'})
#     if result.status == 200
#       #Don't know if this will get the basename
#       json_file_data[file.basename][:id] = results.data.id
#       return true
#     else
#       puts "There was an error inserting your file to drive"
#       return false

#     #RETURN FILE ID
#     end
#   end

#   def file_del fn fid
#     puts "what"
#   end

#   def space_free
#     create_client
#     p @client
#     drive = @client.discovered_api('drive', 'v2')
#     result = @client.execute(:api_method => drive.about.get)
#     if result.status == 200
#       about = result.data
#       return about.quota_bytes_total - about.quota_bytes_used
#     else
#       puts "There was an error with getting the about info from drive"
#       return false
#     end
#   end
# end
