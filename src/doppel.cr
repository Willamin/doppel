module Doppel
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.intercept
    puts "intercepting"
  end

  def self.playback
    puts "playing back"
  end
end
