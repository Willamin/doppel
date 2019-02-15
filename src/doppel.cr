require "http"

module Doppel
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.playback
    puts "playing back"
  end

  class Route
    @path : String
    @response : HTTP::Server::Response

    def initialize(@path, @response); end
  end

  class Server
    @server : HTTP::Server

    def initialize(&block : HTTP::Server::Context -> )
      @server = HTTP::Server.new(block)
    end

    def listen
      address = @server.bind_tcp(8080)
      yield address
      @server.listen
    end
  end
end

class Doppel::Interceptor
  def initialize(host)
    client = HTTP::Client.new(host)
    server = Server.new do |context|
      request = context.request
      request.headers["Host"] = host
      client.exec(request) do |response|
        response.headers.each do |key, values|
          context.response.headers[key] = values
        end
        context.response.status_code = response.status_code
        body = response.body_io.gets_to_end
        context.response.puts(body)
      end
    end

    server.listen do |address|
      puts("forwarding http://#{address} to #{host} and intercepting")
    end
  end
end
