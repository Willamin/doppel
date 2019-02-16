require "http"
require "uuid"
require "./doppel/*"

module Doppel
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.run(host : String)
    uuid = UUID.random
    path = File.expand_path("~/.cache/doppel/#{uuid}.json")
    writer = File.new(path, "w")
    STDERR.puts("storing cache in #{path}")

    server = HTTP::Server.new([
      Doppel::Interceptor.new(writer),
      Doppel::Forwarder.new(host),
    ])

    address = server.bind_tcp(8080)
    puts("#{address} --> #{host}\n")
    server.listen
  end
end
