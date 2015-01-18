require 'net/http'
require 'net/http/post/multipart'
require 'ruby-multipart-post'
require 'rest-client'
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

  def file_put file
    fn = File.basename file.path
    token = @access_token['access_token']
    url = 'https://upload.box.com/api/2.0/files/content'
    resp = `curl -s -H 'Authorization: Bearer #{token}' -H 'Transfer-Encoding: chunked' -H 'Content-Length: #{file.size}' -F "filename=@#{file.path}" -F "folder_id=0" #{url}`
    json = JSON.parse resp
    puts json['entries'][0]['sha1']
    json['entries'][0]['id']
  end

  def file_get fn, fid
    token = @access_token['access_token']
    url = "https://api.box.com/2.0/files/#{fid}/content"
    `curl -L -X GET -H 'Authorization: Bearer #{token}' #{url}`
  end

  def file_del fn, fid
    uri = URI.parse("https://api.box.com/2.0/files/#{fid}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Delete.new(uri.request_uri)
    request.initialize_http_header({
        "Authorization" => "Bearer #{@access_token['access_token']}"
      })
    res = JSON.parse http.request(request).body
    puts res
  end

  def space_free
    uri = URI.parse("https://api.box.com/2.0/users/me")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.initialize_http_header({
        "Authorization" => "Bearer #{@access_token['access_token']}"
      })
    res = JSON.parse http.request(request).body
    (res['space_amount']-res['space_used'])/(1024**3).to_f
  end
end
