class File
  def chunk fn, prefix, chunksize = 4_194_304 # 4MB
    File.open(fn, 'r') do |file|
      until file.eof?
        # sample: f572d396fae9206628714fb2ce00f72e94f2258f_00001 (the sha1 is for file)
        File.open("#{prefix}_#{"%05d"%(file.pos/chunksize)}", "w") do |file_out|
        	# returns list of chunks with their sha1's and refs
          file_out << file.read(chunksize)
        end
      end
    end
  end
end
