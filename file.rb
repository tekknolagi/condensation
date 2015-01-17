require 'digest/sha1'

class File
  def make_chunk size = 131_072 # 128KB
    blob = read(size)
    if not blob
      return nil
    end

    sha1 = Digest::SHA1.hexdigest blob
    fn = "#{sha1}_%05s" % (pos/size.to_f).to_i

    File.open(fn, 'w') do |f|
      f.write blob
    end

    return { :fn => fn, :blob => blob, :sha1 => sha1 } #unless eof?
  end
end
