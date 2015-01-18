require 'json'

class Konfig
  attr_accessor :keys
  attr_accessor :db

  def initialize
    if not Dir.exists?(File.expand_path '~/.condensation')
      Dir.mkdir File.expand_path('~/.condensation')
    end
    if not File.exist?(File.expand_path '~/.condensation/api.json')
      f =File.open(File.expand_path('~/.condensation/api.json'), 'w')
      f.write({ :dropbox => {}, :onedrive => {}, :box => {}}.to_json) # when ready, make sure this includes google as well
      f.close
    end
    if not File.exist?(File.expand_path '~/.condensation/db.json')
      f = File.open(File.expand_path('~/.condensation/db.json'), 'w')
      f.write({ :fn2ref => {}, :chunk2ref => {} }.to_json)
      f.close
    end

    @@api_path = File.expand_path '~/.condensation/api.json'
    @@db_path = File.expand_path '~/.condensation/db.json'
    read
  end

  def exists?
    File.exist? @@api_path
  end

  def read
    @keys = JSON.parse File.read @@api_path
    @db = JSON.parse File.read @@db_path
  end

  def write
    File.open(@@api_path, "w") do |f|
      f.write @keys.to_json
    end

    File.open(@@db_path, "w") do |f|
      f.write @db.to_json
    end
  end
end
