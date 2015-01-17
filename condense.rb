require './file'
require './config'
require './provider'

require 'json'

class Condense
  def self.file_list
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

    # replace fn with prefix
    # store fn prefix relationship in JSON

    most_filled_cloud = get_most_filled_cloud file_size
    if not most_filled_cloud
      chunked_file_list = file.chunk(prefix)
      chunking_handler chunked_file_list       #Call chunking stuff on file that returns the list of chunks (which are themselves files)
    end
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

    file_cloud = get_cloud_of_file_from_fn fn #GET CLOUD OF FILE FROM NAME
    file = Object.const_get(file_cloud).file_get fn

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

  # puts DropboxService.get_token
  # puts DropboxService.file_put File.open('file.rb')
end
