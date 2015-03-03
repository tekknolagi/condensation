require 'json'

class Konfig
  attr_accessor :keys
  attr_accessor :db

  @@cond = '~/.condensation'
  @@api_json = '~/.condensation/api.json'
  @@db_json  = '~/.condensation/db.json'

  def initialize
    if not Dir.exists?(File.expand_path @@cond)
      Dir.mkdir File.expand_path(@@cond)
    end
    if not File.exist?(File.expand_path @@api_json)
      f = File.open(File.expand_path(@@api_json), 'w')
      # when ready, make sure this includes google as well
      f.write({ :dropbox => {}, :onedrive => {}, :box => {} }.to_json)
      f.close
    end
    if not File.exist?(File.expand_path @@db_json)
      f = File.open(File.expand_path(@@db_json), 'w')
      f.write({ :fn2ref => {}, :chunk2ref => {} }.to_json)
      f.close
    end

    @@api_path = File.expand_path @@api_json
    @@db_path = File.expand_path @@db_json
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
