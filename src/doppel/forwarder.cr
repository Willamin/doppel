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
