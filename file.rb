class File
  # return something
  # array of chunk objects with hashes


  #notes: 
  # => we can just pass the file instead of opening it here again
  def chunk fn, prefix, chunksize = 4_194_304 # 4MB
    File.open(fn, 'r') do |file|
    chunk_list = Array.new
      until file.eof?
        # sample: f572d396fae9206628714fb2ce00f72e94f2258f_00001 (the sha1 is for file)
        File.open("#{prefix}_#{"%05d"%(file.pos/chunksize)}", "w") do |file_out|
        	# needs to return a list of chunks with their sha1's and refs
        	File.open(file_out, "w") do |actual_file|
        		chunk_list.push(file_out)
        	end
       #   file_out << file.read(chunksize)
        end

        return chunk_list
        
      end
    end
  end
end
