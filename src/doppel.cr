require "http"

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

class Doppel::Response
  property! body : String
  property! headers : HTTP::Headers
  property! status_code : Int32
end

class Doppel::Interceptor
  include HTTP::Handler

  def initialize
    @cache = Hash(String, Doppel::Response).new
  end

  def call(context : HTTP::Server::Context)
    request = context.request
    if cached_response = @cache[request.path]?
      STDERR.puts("serving #{request.method} #{request.path}")
      context.response.status_code = cached_response.status_code
      cached_response.headers.each do |key, values|
        context.response.headers[key] = values
      end
      context.response.puts(cached_response.body)
    else
      io = IO::Memory.new
      original_output = context.response.output
      context.response.output = IO::MultiWriter.new(io, original_output, sync_close: true)
      call_next(context)
      to_save = Doppel::Response.new
      to_save.status_code = context.response.status_code
      to_save.headers = context.response.headers
      to_save.body = io.rewind.gets_to_end
      pp to_save
      @cache[request.path] = to_save
    end
  end
end

class Doppel::Forwarder
  include HTTP::Handler

  def initialize(host : String)
    @client = HTTP::Client.new(host)
  end

  def call(context : HTTP::Server::Context)
    request = context.request
    STDERR.puts("fetching #{request.method} #{request.path}")
    # client --> doppel --> server
    request.headers["Host"] = @client.host
    response = @client.exec(request)

    # client <-- doppel <-- server
    context.response.status_code = response.status_code
    response.headers.each do |key, values|
      context.response.headers[key] = values
    end

    body = response.body_io?.try(&.gets_to_end) || response.body
    context.response.puts(body)
  end
end
