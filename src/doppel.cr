require "http"
require "./doppel/*"

module Doppel
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  class ::HTTP::Server
    def bind_and_listen(port)
      address = self.bind_tcp(port)
      yield address
      self.listen
    end
  end

  def self.run(host : String)
    server = HTTP::Server.new([
      Doppel::Interceptor.new,
      Doppel::Forwarder.new(host),
    ])

    server.bind_and_listen(8080) do |address|
      puts("#{address} --> #{host}\n")
    end
  end
end
