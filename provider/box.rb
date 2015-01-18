require 'net/http'
require 'json'
require 'launchy'

class Provider ; end

class BoxService < Provider
  AUTH_URL = 'http://condensation-auth.herokuapp.com/box'
  attr_accessor :access_token

  def get_api_token code
    JSON.parse Net::HTTP.post_form(URI("#{AUTH_URL}/api_token"), { :code => code }).body
  end

  def get_token
    # Make GET to auth server/build_url
    authorize_url_json = Net::HTTP.post_form(URI("#{AUTH_URL}/build_url"), {})
    parsed_json = JSON.parse(authorize_url_json.body)
    authorize_url = parsed_json['authorize_url']

    # Launchy(authorize_url)
    Launchy.open(authorize_url)
    puts 'Please authorise Condensation for your Box account:'
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip.gsub("\"","")

    # Send code to Box for access_token
    get_api_token code
  end

  def file_put
    token = @access_token['access_token']
  end

  def file_get
  end

  def space_free
  end
end
