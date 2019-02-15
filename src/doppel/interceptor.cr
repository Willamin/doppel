require "json"

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
      tee = IO::Memory.new
      original_output = context.response.output
      context.response.output = IO::MultiWriter.new(tee, original_output, sync_close: true)
      call_next(context)

      @cache[request.path] = Doppel::Response.new(
        context.response.status_code,
        context.response.headers,
        tee.rewind.gets_to_end
      )
    end
  end
end

class Doppel::Response
  property status_code : Int32
  property headers : HTTP::Headers
  property body : String

  def initialize(@status_code, @headers, @body); end

  JSON.mapping(
    status_code: Int32,
    headers: HTTP::Headers,
    body: String,
  )
end
