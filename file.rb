require 'digest/sha1'

class File
  def make_chunk prefix, size = 131_072 # 128KB default chunk size
    blob = read(size)
    if not blob
      return nil
    end

#    fn = "#{prefix}_%05d" % (pos/size.to_f).to_i
    fn = Digest::SHA1.hexdigest blob # make fn the chunk hash

    File.open(fn, 'w') do |f|
      f.write blob
    end

    return { :fn => fn, :blob => blob} #unless eof?
  end
end
