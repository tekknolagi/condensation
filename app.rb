require './file'
require './provider'

module Condense
  puts DropboxService.get_token
  puts DropboxService.file_put File.open('file.rb')
end


