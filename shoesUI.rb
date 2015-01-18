require './file'
require './config'
require './provider'
require './condense'

condenser = Condense.new

Shoes.app {
  puts "HELLO"

  @note = para ""
  
  stack {
    flow do 
      @filename = edit_line
      @upload = button "Upload"
    end
    @download = button "Download"
  }

  @upload.click{
    if not @filename
      puts "Messed up"
    end
    puts condenser.file_put @filename
  }

  stack {
    button "Add Google Account"
    button "Add Dropbox Account"
    button "Add OneDrive Account"
  }

}