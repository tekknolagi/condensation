require 'json'

module Konfig
  @@path = '~/.condensation/api.json'
  @@name = File.expand_path @@path
  attr_accessor :keys

  def self.exists?
    File.exist? @@name
  end

  def self.read
    @keys = JSON.parse File.read @@name
  end

  def self.write
    File.open(@@path) do |f|
      f.write keys.to_json
    end
  end
end
