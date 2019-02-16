require "json"

class Doppel::Interceptor
  include HTTP::Handler

  def initialize(@file : File)
    @cache = Hash(String, Doppel::Response).new

    Signal::INT.trap do
      print "saving cache..."
      @file.puts(@cache.to_json)
      @file.close
      puts "done!"
      exit(0)
    end
  end

  def call(context : HTTP::Server::Context)
    request = context.request

    cache_path = [request.method, request.path].join(" ")

    if cached_response = @cache[cache_path]?
      STDERR.puts("serving #{cache_path}")
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

      @cache[cache_path] = Doppel::Response.new(
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
