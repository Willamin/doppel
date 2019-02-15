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
      @cache[request.path] = to_save
    end
  end
end

class Doppel::Response
  property! body : String
  property! headers : HTTP::Headers
  property! status_code : Int32
end
