require 'rubygems'
require 'google/api_client'
require 'launchy'

module Google
  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/google/'

  # There are some issues with trying to split this up into a proper client-server for client auth
  # See this: https://developers.google.com/drive/web/quickstart/quickstart-ruby
  def get_token
    # POST request to auth server to get authorization url
    authorize_url_json = Net::HTTP.post_form(URI.parse(AUTH_URL+'authorize'))
    parsed_json = JSON.parse(authorize_url_json)
    authorize_url = parsed_json['authorize_url']

    # Have the user sign in and authorize this app
    puts 'Please authorise Condensation for your Google account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip

    # POST request to auth server to get client access token
    access_token_json = Net::HTTP.post_form(URI.parse(AUTH_URL+'api_token'), {'code' => code})
    parsed_json = JSON.parse(access_token_json)
    @@access_token = parsed_json['access_token']
  end

  def file_get
  end

  def file_put
  end

  def file_list
  end

  def space_free
  end
end
