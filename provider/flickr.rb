require 'flickraw'
require 'net/http'
require 'json'
require 'launchy'

class Provider; end

class FlickrService < Provider
  AUTH_SERVER = 'http://condensation-auth.herokuapp.com/flickr'
  attr_accessor :access_token

	def get_secrets
		secrets = Net::HTTP.get(URI.parse("#{AUTH_SERVER}/secrets"))
    secrets = JSON.parse(secrets)
	end

  def access_token= tok
		@access_token = tok
		FlickRaw.api_key = tok['api_key']
		FlickRaw.shared_secret = tok['api_secret']
 		flickr.access_token = tok['access_token']
		flickr.access_secret = tok['access_secret']
	end

  def get_token
		@secrets = get_secrets
		token = flickr.get_request_token
		authorize_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')
		Launchy.open(authorize_url)

		    # Have the user sign in and authorize this app
		puts 'Please authorise Condensation for your Flickr account:'
		puts '1. Go to: ' + authorize_url
		puts '2. Click "Allow" (you might have to log in first)'
		puts '3. Copy the authorization code'
		print 'Enter the authorization code here: '
		code = gets.strip

		begin
			token = flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], code)
			login = flickr.test.login
			return {
				:access_secret => token['oauth_token_secret'],
				:access_token => token['oauth_token'],
				:api_key => FlickRaw.api_key,
				:api_secret => FlickRaw.shared_secret
			}
		rescue FlickRaw::FailedResponse => e
			puts "Authentication failed : #{e.msg}"
			return nil
		end
  end

  def file_get fn
    # ignore metadata for now
    client = DropboxClient.new @access_token
    client.get_file_and_metadata File.join('/', fn)
  end

  def file_put file
    fn = File.basename file.path

    # Upload all files flat under apps dir root
    # Good practice would be to inspect the response to make sure everything's ok
		p get_secrets
		flickr.upload_photo fn, :title => "Title", :description => "Description"
  end

  def space_free
    #client = DropboxClient.new @access_token
    #account_parsed = client.account_info
    #quota_info = account_parsed['quota_info']

    # Assuming this adds up to total storage used by the user
    #used_storage = quota_info['normal'].to_i + quota_info['shared'].to_i
    #bytes_free = quota_info['quota'].to_i - used_storage
    #bytes_free / 1048576.0 # return megabytes free (1024*1024)
		return 1024*1024
  end
end
