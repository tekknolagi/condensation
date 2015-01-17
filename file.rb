class File
  # return something
  # array of chunk objects with hashes
  def chunk fn, prefix, chunksize = 4_194_304 # 4MB
    File.open(fn, 'r') do |file|
      until file.eof?
        # sample: f572d396fae9206628714fb2ce00f72e94f2258f_00001
        File.open("#{prefix}_#{"%05d"%(file.pos/chunksize)}", "w") do |file_out|
          file_out << file.read(chunksize)
        end
      end
    end
  end
end
