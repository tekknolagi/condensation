#require './file'
#require './config'
#require './provider'
#require './condense'

#pp = Condense.new

Shoes.app(title: "Condenser",
   width: 190, height: 600, resizable: false) {


  stack {
    @note = para "Hello"
    @config = button   "       Config       "
    @list = button     "        List        "
    @upload = button   "       Upload       "
    @space = button    "        Space       "
    @download = button "      Download      "
    @delete = button   "       Delete       "

    @Box = button   "   Add Box Account  "
    @Dropbox = button  "Add Dropbox Account "
    @OneDrive = button "Add OneDrive Account"

    @sha = button      "       getSha       "

    @amountLeft = para ""
    @amountBar = progress width: 1.0

    @fileList = para ""
  }

   @config.click {
      service = ask("Please Enter a Service to Configure")
      if not service
        @note.replace "There is no service listed"
        return
      end

      app.configure service

      #check to make sure these are the right function names for total size in cloud and amount used in cloud
      print_current_size condense.get_total_size condense.get_amount_used
    }

  @list.click {
    file_list = app.file_list

    file_list.each do |file, ref|
      text = text + file + "\n"
    end

    @fileList.replace text
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

  @space.click {
    @amountLeft.replace "HERRO"
    counter = 0
    cloud_data = app.get_cloud_usage
    cloud_data.each do |cloud_name, data|
      counter += data
    end
    @amountLeft.replace counter
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

  @sha.click {
    filename = ask("Please Enter a File Name")
    if not filename
      @note.replace "There is no file name listed"
      return
    end

    app.hash2fn filename
  }



  @Box.click {
    app.configure box
  }

  @Dropbox.click {
    app.configure dropbox
  }

  @OneDrive.click {
    app.configure onedrive
  }
}