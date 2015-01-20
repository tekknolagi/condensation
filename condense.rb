require './file'
require './config'
require './provider'
require 'digest/sha1'
require 'rake/pathmap'
require 'json'

class Condense
  attr_accessor :config
  attr_accessor :services
  CHUNK_SIZE = 1024**2 # 1 MB

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

  def configure service
    if service
      @config.keys[service] = @services[service].get_token
    else
      @services.each do |svc, obj| # svc was shadowed earlier, method param renamed to 'service'
        @config.keys[svc] = obj.get_token if @config.keys[svc] == {}
      end
    end
  end

  def file_list
    @config.db["fn2ref"].map do |sha, ref|
      print "#{ref['fn'].split('!').join('/')}: "
      ref['chunks'].map do |chunk|
        print "#{chunk}(#{@config.db['chunk2ref'][chunk]['service']})"
      end
      print "\n"
    end
  end

  def fn2hash fn
    shas = @config.db["fn2ref"].keys
    shas.each do |sha|
      if @config.db["fn2ref"][sha]["fn"] == fn.split('/').join('!')
        return sha
      end
    end
    return "Hash not found."
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

    if File.zero? fn
      puts "There was an error: the fn returned an empty file"
      return false
    end

    if @config.db["fn2ref"].has_key? prefix # hash is in database - identical file exists in cloud
      puts "There was an error: this file already exists, or has an identical version uploaded"
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
      while counter * CHUNK_SIZE < most_filled_cloud[1]
        chunk = file.make_chunk(prefix, CHUNK_SIZE)
        if not chunk
          continuing = false
          break
        end
        
        if not @config.db["chunk2ref"].has_key? chunk[:fn] # If this chunk doesn't already exist, upload it
          fid = @services[most_filled_cloud[0]].file_put File.open(chunk[:fn], 'rb')
          File.unlink(chunk[:fn])

          # Store storage service and fid (if applicable) of each chunk
          # Keep track of each chunk by its hash
          @config.db["chunk2ref"][chunk[:fn]] = {
            :service => most_filled_cloud[0],
            :id => fid
          }
        end

        shas.push chunk[:fn]
        counter += 1
      end
    end

    @config.db["fn2ref"][prefix] = {
      :fn => fn.split('/').join('!'),
      :chunks => shas
    }

    true
  end

  # Handler for downloading files. Returns true if the file download worked, false if it failed any point along the way.
  # NOTE: This seems to have been deprecated during development, and should probably be removed - Arun
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
      puts "There was an error: the sha1 does not exist"
      return false
    end

    #Decompose the json objects here
    record = @config.db["fn2ref"][sha1]

    # Convert filename back to relative path, but append a suffix to the end
    rel_path = record["fn"].split('!').join('/')
    fp = rel_path.pathmap "%X-#{rand 99}%x"

    file_chunks = record["chunks"] # file_chunks needs to sort the chunks by their names' last 5 digits

    # Assemble/concatenate chunks back together
    File.open(File.expand_path(fp), "w") do |f|
      file_chunks.each do |chunk|
        name = @config.db["chunk2ref"][chunk]["service"]
        fid = @config.db["chunk2ref"][chunk]["id"]
        f.write @services[name].file_get(chunk, fid) # expects file_get to return plaintext file contents
      end
    end

    return true
  end

  def file_del sha1
    if not sha1
      puts "There was an error: the sha1 was nil"
      return false
    end

    if not @config.db["fn2ref"].has_key?(sha1)
      puts "There was an error: the sha1 does not exist"
      return false
    end

    # Map over array of the other file hashes
    # For each hash, find the intersect between its chunks and this hash's chunks and accumulate
    other_shas = @config.db['fn2ref'].keys - [sha1]
    shared_chunks = other_shas.map do |sha|
      @config.db['fn2ref'][sha1]['chunks'] & [sha]
    end.inject(:<<) || []

    to_delete = @config.db["fn2ref"][sha1]["chunks"] - shared_chunks

    # Map over array of chunks to delete in the cloud
    # Also delete them from chunk2ref
    to_delete.map do |chunk|
      name = @config.db['chunk2ref'][chunk]['service']
      # chunk is filename, also pass chunk's id
      @services[name].file_del(chunk, @config.db['chunk2ref'][chunk]['id'])
      @config.db['chunk2ref'].delete chunk # this chunk no longer exists in the cloud
    end

    # Delete sha1 entry in db
    @config.db['fn2ref'].delete sha1 

    return true
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
