require './file'
require './config'
require './provider'
require './condense'

require 'optparse'

app = Condense.new

OptionParser.new do |opts|
  opts.banner += " [arguments...]"
  opts.separator "This will parse commands to be used by Condensation"
  opts.version = "0.0.0"

  opts.on("-c", "--configure [SERVICE]", "Sign into your services (dropbox | onedrive | box | google)") do |svc|
    app.configure svc
  end

  opts.on("-l", "--list", "Returns list of files in the cloud") do
    puts app.file_list
  end

  opts.on("-u", "--upload FILEPATH", "Uploads the file at FILEPATH") do |args|
    app.file_put args
  end

  opts.on("-s", "--space [SERVICE]", "Get the amount of free space from a provider(s)") do |svc|
    if not svc
      puts app.get_cloud_usage
    else
      puts app.services[svc].space_free
    end
  end

  opts.on("-d", "--download FILENAME", "Downloads the file named FILENAME") do |args|
    puts app.file_get args
  end

  opts.on("-x", "--delete FILENAME", "Deletes the file named FILENAME") do |args|
    puts app.file_del args
  end

  opts.on("-S", "--SHA FILENAME", "Retrieve the database SHA-1 hash for FILENAME") do |args|
    puts app.hash2fn args
  end

  begin
    opts.parse!

  rescue OptionParser::ParseError => error
    $stderr.puts error
    $stderr.puts "(-h or --help will show valid options)"
    exit 1
  end
end

app.persist!
