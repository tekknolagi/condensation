require 'json'

module Konfig
  @@name = File.expand_path '~/.condensation/api.json'
  attr_accessor :keys

  def self.exists?
    File.exist? @@name
  end

  def self.read
    @keys = JSON.parse File.read @@name
  end

  def self.write
  end
end
