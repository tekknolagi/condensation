require './file'
require './config'
require './provider'

require 'json'

class Condense
  def self.file_put fn
    if not fn
      puts "There was an error: the fn was nil"
      return false
    end

    if not File.zero? fn
      puts "There was an error: the fn returned an empty file"
      return false
    end

    cloud_list = condense.get_clouds
    total_space = cloud_list.map do |name|
      total_space += Object.const_get(name).space_free
    end.inject(:+)
    file_size = File.size(fn)

    if file_size > total_space
      puts "This file was too large"
      return false
    end

    file = File.open(fn)
    most_filled_cloud = get_most_filled_cloud file_size
    Object.const_get(most_filled_cloud).file_put fn, file
    return true
  end

  def download_from_cloud_handler(fn)
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
      download_file file
      return true
    end
  end

  def get_cloud_usage
    Konfig.keys.keys.map do |key|
      Object.const_get(file_cloud).space_free
    end
  end

  def get_most_filled_cloud(file_size)
    cloud_usage_list = Condense.get_cloud_usage
    min_size = cloud_usage_list.select do |name, size|
      size > file_size
    end.min_by do |name, size|
      size
    end[0]

    if not min_size
      #Call chunking stuff here
    else
      return min_size
    end
  end

  # puts DropboxService.get_token
  # puts DropboxService.file_put File.open('file.rb')
end


