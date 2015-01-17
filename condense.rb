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
  def self.file_list
    json_file_data.each do |filename, properties|
      puts "#{filename}-----"
      puts properties
    end
  end

  #get_clouds returns a list of clouds that are currently connected to the users files
  def self.get_clouds
    Konfig.keys.map do |key, val|
      key
    end
  end

  #Handler for uploading files. Returns true if the file upload worked, false if it failed at any point along the way. 
  #Also handles chunking
  def self.file_put fn
    if not fn
      puts "There was an error: the fn was nil"
      return false
    end

    if json_file_data.has_key?(fn)
      puts "There was an error: this file name already exists"
      return false
    end

    if not File.zero? fn
      puts "There was an error: the fn returned an empty file"
      return false
    end

    fn = fn.split('/').join('!')

    cloud_list = Condense.get_clouds
    total_space = cloud_list.map do |name|
      total_space += Object.const_get(name).space_free
    end.inject(:+)
    file_size = File.size(fn)

    if file_size > total_space
      puts "This file was too large"
      return false
    end

    file = File.open(fn)

    content = File.open(fn, "rb").read()
    prefix = Digest::SHA1.hexdigest content
    
    file_properties = Hash.new

    most_filled_cloud = get_most_filled_cloud file_size
    if not most_filled_cloud
      chunked_file_list = file.chunk(prefix)
      chunk_table = chunking_handler chunked_file_list 
      if not chunk_table
        puts "There was a critical error"
        return false
      else
        file_properties[:chunk_table] = chunk_table
      end
    end

    #would need to pass the database id at some point, after the API code return (at least, for things like drive) 
    file_properties[:prefix] = prefix
    file_properties[:cloud_name] = most_filled_cloud 

    #NOTE: Made this different from using the prefix as vector. User will never search for files by prefix, but will by filename. The solution is to 
    #add function that checks to make sure filename is unique, and prevents user otherwise (see above)
    
    json_file_data[:file_name] = fn

    #Write JSON file data to a file stored somewhere

    Object.const_get(most_filled_cloud).file_put fn, file
    
    return true
  end

  #Handler for downloading files. Returns true if the file download worked, false if it failed any point along the way. 
  def self.file_write file
    filename = File.basename(File.path(file))
    File.open(filename, "w") do |f|
      f.write(file)
    end
  end

  def self.file_get fn
    if not fn
      puts "There was an error: the fn was nil"
      return false
    end

    if not json_file_data.has_key?(fn)
      puts "There was an error: the fn doesn't previously exists"
      return false
    end

    #Decompose the json objects here
    json_file_obj = json_file_data[fn]

    file_prefix = json_file_obj["prefix"]

    file_cloud = json_file_obj["cloud_name"]

    if json_file_obj.has_key?("chunk_table")
      #REBUILD CHUNKING THINGS HERE
    else
      file = Object.const_get(file_cloud).file_get prefix 
    end

    if not file
      puts "There was an error getting the file"
      return false
    else
      Condense.file_write file
      return true
    end
  end

  #returns a list of free data (value) per cloud (key)
  def get_cloud_usage
    Konfig.keys.keys.map do |key|
      Object.const_get(file_cloud).space_free
    end
  end

  #returns the name (string) of the cloud that is most filled BUT STILL FITS THE FILE_SIZE
  #calls chunking if needed
  def get_most_filled_cloud(file_size)
    cloud_usage_list = Condense.get_cloud_usage
    min_size = cloud_usage_list.select do |name, size|
      size > file_size
    end.min_by do |name, size|
      size
    end[0]

    if not min_size
      return false
    else
      return min_size
    end
  end

  #This function assists the main uploader handler by taking the list of chunks produced for too-large files
  # and storing them in various clouds using get_most_filled_cloud
  def chunking_handler(list_of_chunks)

    chunk_table = Hash.new

    list_of_chunks.each { |chunk| 
      most_filled_cloud = get_most_filled_cloud chunk.size

      #Not sure how to get filename of a file thats already instantiated <THIS NEEDS CHECKING

      chunk_table[:chunk.basename] = chunk
      Object.const_get(most_filled_cloud).file_put chunk.basename, chunk
    }

    return chunk_table

  end

  # puts DropboxService.get_token
  # puts DropboxService.file_put File.open('file.rb')
end
