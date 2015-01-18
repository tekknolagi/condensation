require 'json'
require 'launchy'
require 'google/api_client'

class Provider; end

class GoogleService < Provider

  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/google'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

  attr_accessor :access_token

  # There are some issues with trying to split this up into a proper client-server for client auth
  # See this: https://developers.google.com/drive/web/quickstart/quickstart-ruby
  def get_token
    puts "1"
    create_client
    authorize_url = @client.authorization.authorization_uri
    puts "2"
    # Have the user sign in and authorize this app
    Launchy.open(authorize_url)
    puts 'Please authorise Condensation for your Google account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    @client.authorization.code = gets.chomp
    @client.authorization.fetch_access_token!
    puts "3"
    # Preload API definitions
    client = Google::APIClient.new
    set :drive, client.discovered_api('drive', 'v2')
    set :oauth2, client.discovered_api('oauth2', 'v2')
    puts "4"
    ##
    # Exchanges the authorization code to fetch an access
    # and refresh token. Stores the retrieved tokens in the session.
    def authorize_code(code)
      puts "8"
      api_client.authorization.code = code
      api_client.authorization.fetch_access_token!
      # put the tokens in the session
      puts "9"
      session[:access_token] = api_client.authorization.access_token
      session[:refresh_token] = api_client.authorization.refresh_token
      session[:expires_in] = api_client.authorization.expires_in
      session[:issued_at] = api_client.authorization.issued_at
      puts "10"
    end

    puts "5"
       # Make sure access token is up to date for each request
      api_client.authorization.update_token!(session)

      # if existing access token is expired and refresh token is set,
      # ask for a new access token.
      if api_client.authorization.refresh_token &&
        api_client.authorization.expired?
        api_client.authorization.fetch_access_token!
      end

      puts "6"

      
      puts "7"
      # handle possible callback from OAuth2 consent page.
      if params[:code]
        authorize_code(params[:code])
        redirect '/'
        puts "IT WORKED"
      elsif params[:error] # User denied the oauth grant
        halt 403
        puts "IT FAILED"
      end

      redirect api_client.authorization.authorization_uri.to_s unless authorized?
      

    # At this point I believe the client is all set up (authenticated and whatnot)
    # To do is still: Figure out how we can avoid doing all this all over each time app.rb is run => The web based version of this (JS gapi) uses cookies; that part of the api is not open to devs
    # I imagine they did not intend for their apis to be used in a local system like this; increasingly I think this is a hole in the API
  end 

  def create_client
    # Create a new API client & load the Google Drive API
    @client = Google::APIClient.new({ :application_name => 'Condensation', :application_version => '0.0.0' })
    @drive = @client.discovered_api('drive', 'v2')

    # POST request to auth server to get JSON of api keys
    secrets = Net::HTTP.get(URI.parse("#{AUTH_SERVER}/secrets"))
    api_secrets = JSON.parse(secrets)
    client_id = api_secrets['key']
    client_secret = api_secrets['secret']

    # Request authorization
    @client.authorization.client_id = client_id
    @client.authorization.client_secret = client_secret
    @client.authorization.scope = OAUTH_SCOPE
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.access_token = @access_token if @access_token
  end

  def file_get fn
    create_client
    file_properties = json_file_data[fn]
    google_id = file_properties["id"]

    #starts callback flow
    result = @client.execute(
      :api_method => @drive.files.get,
      :parameters => { 'fileId' => file_id })
    if result.status == 200
      file = result.data
      if file.download_url
        result = @client.execute(:uri => file.download_url)
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

  def file_put file
    create_client
    drive = @client.discovered_api('drive', 'v2')
    file = drive.files.insert.request_schema.new({
      #metadata for later
    })

    # Set the parent folder.
    if parent_id
      file.parents = [{'id' => parent_id}]
    end
    media = Google::APIClient::UploadIO.new(file_name, "application/octet-stream")
    result = @client.execute(
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
  end

  def space_free
    create_client
    p @client
    drive = @client.discovered_api('drive', 'v2')
    result = @client.execute(:api_method => drive.about.get)
    if result.status == 200
      about = result.data
      return about.quota_bytes_total - about.quota_bytes_used
    else
      puts "There was an error with getting the about info from drive"
      return false
    end
  end
end
