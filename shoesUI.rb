#require './file'
#require './config'
#require './provider'
#require './condense'

#app = Condense.new


Shoes.app(title: "Condenser",
   width: 190, height: 600, resizable: false) {


  stack {
    @note = para "Hello"
    @upload = button "       Upload       "
    @download = button "      Download      "
    @delete = button "       Delete       "

    @Google = button "Add Google Account  "
    @Dropbox = button "Add Dropbox Account "
    @OneDrive = button "Add OneDrive Account"

    @amountLeft = para ""
    @amountBar = progress width: 1.0

  }

  @upload.click {
    filepath = ask("Please Enter a File Path to Upload a File")
    if not filepath
      @note.replace "There is no file path listed"
      return
    end

    app.file_put filepath

    #check to make sure these are the right function names for total size in cloud and amount used in cloud
    print_current_size condense.get_total_size condense.get_amount_used
  }

  @download.click {
    filename = ask("Please Enter a File Name to Download a File")
    if not filename
      @note.replace "There is no file name listed"
      return
    end

    app.file_get filename
  }

  @delete.click {
    filename = ask("Please Enter a File Name to Delete")
    if not filename
      @note.replace "There is no file name listed"
      return
    end

    app.file_del filename
  }

  @Google.click {
    app.configure Google
  }

  @Dropbox.click {
    app.configure Dropbox
  }

  @OneDrive.click {
    app.configure OneDrive
  }

  def print_file_list
    list = app.file_list

    #Not sure if this works like it is supposed to
    list.each do |filename, properties|
      @temp = button filename
      @temp.click {
        app.file_get filename
      }
    end
  end


  def print_current_size total_size amount_used
    percent_used = amount_used/total_size
    amount_left = total_size - amount_used
    @amountBar.fraction = percent_used
    amount_left = amount_left + " mb"
    @amountLeft.replace amount_left
  end

  print_file_list #generates the files below the rest of the buttons

}