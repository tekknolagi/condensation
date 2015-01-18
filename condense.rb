require './file'
require './config'
require './provider'
require 'digest/sha1'

require 'json'


#Do we want to create a 'master Hash' that loads on start up and basically puts all of the data from the json hash database into the app at the start?
#OR
#Do we want to constantly query the json database itself?
#
#That will affect how we write to JSON; I'm assuming we do the first, and edit a global hash called json_file_data that writes to a file when things change in it

class Condense
  attr_accessor :config
  attr_accessor :services

  def initialize
    @config = Konfig.new
    @services = @config.keys.map do |key, val|
      [key, Object.const_get("#{key.capitalize}Service").new]
    end.to_h
    @services.map do |svc, obj|
      obj.access_token = @config.keys[svc]
    end
  end

  def persist!
    @config.write
  end

  def configure svc
    if svc
      @config.keys[svc] = @services[svc].get_token
    else
      @services.each do |svc, obj|
        @config.keys[svc] = obj.get_token if @config.keys[svc] == {}
      end
    end
  end

  def file_list
    @config.db["fn2ref"].to_json
  end

  #get_clouds returns a list of clouds that are currently connected to the users files
  def get_clouds
    @config.keys.map do |key, val|
      key
    end
  end

  #Handler for uploading files. Returns true if the file upload worked, false if it failed at any point along the way.
  #Also handles chunking
  def file_put fn
    prefix = Digest::SHA1.hexdigest(File.open(fn, "rb").read)

    if @config.db["fn2ref"].has_key? prefix
      puts "There was an error: this file name already exists"
      return false
    end

    if File.zero? fn
      puts "There was an error: the fn returned an empty file"
      return false
    end

    total_space = get_clouds.map do |name|
      @services[name].space_free
    end.inject(:+)
    file_size = File.size(fn)/(1024**2).to_f

    if file_size > total_space
      puts "This file was too large"
      return false
    end

    file = File.open(fn, "rb")

    shas = []
    continuing = true
    while (most_filled_cloud = get_most_filled_cloud(file_size)) && continuing
      counter = 0
      while counter * 1024**2 < most_filled_cloud[1]
        chunk = file.make_chunk(prefix, 1024**2)
        if not chunk
          continuing = false
          break
        end
        @services[most_filled_cloud[0]].file_put File.open(chunk[:fn], 'rb')
        File.unlink(chunk[:fn])
        @config.db["chunk2ref"][chunk[:sha1]] = most_filled_cloud[0]
        shas.push chunk[:sha1]
        counter += 1
      end
    end

    @config.db["fn2ref"][prefix] = {
      :fn => fn.split('/').join('!'),
      :chunks => shas
    }

    true
  end

  #Handler for downloading files. Returns true if the file download worked, false if it failed any point along the way.
  def file_write file
    filename = File.basename File.path file
    File.open(filename, "w") do |f|
      f.write(file)
    end
  end

  def file_get sha1
    if not sha1
      puts "There was an error: the sha1 was nil"
      return false
    end

    if not @config.db["fn2ref"].has_key?(sha1)
      puts "There was an error: the sha1 doesn't previously exists"
      return false
    end

    #Decompose the json objects here
    record = @config.db["fn2ref"][sha1]
    prefix = record["prefix"]
    provider = record["provider"]

    #    if json_file_obj.has_key?("chunks")
    #REBUILD CHUNKING THINGS HERE
    puts "REBUILD"
    file = nil
    #    else
    #      file = file_cloud).file_get prefix
    #    end

    if not file
      puts "There was an error getting the file"
      return false
    else
      file_write file
      return true
    end
  end

  #returns a list of free data (value) per cloud (key)
  def get_cloud_usage
    @config.keys.keys.map do |key|
      [key, @services[key].space_free]
    end.to_h
  end

  #returns the name (string) of the cloud that is most filled BUT STILL FITS THE FILE_SIZE
  #returns false if chunking is needed
  def get_most_filled_cloud file_size
    cloud_usage_list = get_cloud_usage
    min_size = cloud_usage_list.select do |name, size|
      size > file_size
    end.min_by do |name, size|
      size
    end

    if not min_size
      return false
    else
      return min_size
    end
  end
end
