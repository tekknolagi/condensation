class File
  def chunk fn, prefix, chunksize = 4_194_304 # 4MB
    File.open(fn, 'r') do |file|
      until file.eof?
        File.open("#{prefix}_#{"%05d"%(file.pos/chunksize)}", "w") do |file_out|
          file_out << file.read(chunksize)
        end
      end
    end
  end
end
