require 'digest/sha1'

class File
  def make_chunk prefix, size = 131_072 # 128KB default chunk size
    blob = read(size)
    if not blob
      return nil
    end

    sha1 = Digest::SHA1.hexdigest blob
#    fn = "#{prefix}_%05d" % (pos/size.to_f).to_i
    fn = sha1 # make fn the chunk hash

    File.open(fn, 'w') do |f|
      f.write blob
    end

    return { :fn => fn, :blob => blob, :sha1 => sha1 } #unless eof?
  end
end
