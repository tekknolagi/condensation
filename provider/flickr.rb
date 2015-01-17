require 'flickraw'
require 'net/http'
require 'json'
require 'launchy'

class Provider; end

class FlickrService < Provider
  AUTH_URL = 'http://condensation-auth.herokuapp.com/dropbox'
  attr_accessor :access_token

  def get_token
    # @access_token
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
    client = DropboxClient.new @access_token
    client.put_file File.join('/', fn), file
  end

  def space_free
    client = DropboxClient.new @access_token
    account_parsed = client.account_info
    quota_info = account_parsed['quota_info']

    # Assuming this adds up to total storage used by the user
    used_storage = quota_info['normal'].to_i + quota_info['shared'].to_i
    bytes_free = quota_info['quota'].to_i - used_storage
    bytes_free / 1048576.0 # return megabytes free (1024*1024)
  end
end
