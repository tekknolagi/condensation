require 'rubygems'
require 'json'
require 'launchy'
require 'google/api_client'

class Provider; end

class GoogleService < Provider
  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/google/'

  # Get your credentials from the console
  CLIENT_ID = '772741663299-kodvshk0l6vba9q7etio0vs62cl1d52h.apps.googleusercontent.com'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'

  client = Google::APIClient.new
  drive = client.discovered_api('drive', 'v2')

  # There are some issues with trying to split this up into a proper client-server for client auth
  # See this: https://developers.google.com/drive/web/quickstart/quickstart-ruby
  def self.get_token
    # POST request to auth server to get JSON of api keys
    secrets = Net::HTTP.get(URI.parse(AUTH_SERVER+'secrets'))
    api_secrets = JSON.parse(secrets)
    api_key = api_secrets['key']
    api_secret = api_secrets['secret']

    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = api_secret
    client.authorization.scope = OAUTH_SCOPE

    uri = client.authorization.authorization_uri
    Launchy.open(uri)

    # Exchange authorization code for access token
    $stdout.write  "Enter authorization code: "
    client.authorization.code = gets.chomp
    client.authorization.fetch_access_token!
  end

  def self.file_get fn
    file_properties = json_file_data[fn]
    google_id = file_properties["id"]

    #starts callback flow
    drive = client.discovered_api('drive', 'v2')
    result = client.execute(
      :api_method => @drive.files.get,
      :parameters => { 'fileId' => file_id })
    if result.status == 200
      file = result.data
      if file.download_url
        result = client.execute(:uri => file.download_url)
        if result.status == 200
          return result.body
        else
          puts "There was an error downloading the file from drive"
          return false
        end
      else
        puts "Error: File did not have downloadable content"
        return false
      end
    else
      puts "There was an error getting file from fileId, check file name again"
      return false
    end
  end

  def self.file_put file
    drive = client.discovered_api('drive', 'v2')
    file = drive.files.insert.request_schema.new({
      #metadata for later
    })

    fn = File.basename file.path

    media = Google::APIClient::UploadIO.new(fn, "application/octet-stream")
    result = client.execute(
      :api_method => drive.files.insert,
      :body_object => file,
      :media => media,
      :parameters => {
        'uploadType' => 'multipart',
        'alt' => 'json'})
    if result.status == 200
      #Don't know if this will get the basename
      json_file_data[file.basename][:id] = results.data.id
      return true
    else
      puts "There was an error inserting your file to drive"
      return false
  end

  def self.space_free
    drive = client.discovered_api('drive', 'v2')
    result = client.execute(:api_method => drive.about.get)
    if result.status == 200
      about = result.data
      return about.quota_bytes_total - about.quota_bytes_used
    else
      puts "There was an error with getting the about info from drive"
      return false
    end
  end
end
end
