require "http"
require "./doppel/*"

module Doppel
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.run(host : String)
    server = HTTP::Server.new([
      Doppel::Interceptor.new,
      Doppel::Forwarder.new(host),
    ])

    address = server.bind_tcp(8080)
    puts("#{address} --> #{host}\n")
    server.listen
  end
end
