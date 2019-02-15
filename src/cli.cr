require "option_parser"
require "./doppel"

todo = :nothing
forwarding_host? : String? = nil

parser = OptionParser.new do |parser|
  parser.banner = "usage: doppel [OPTIONS]"

  parser.on("-v", "--version", "display the version") { todo = :version }
  parser.on("-h", "--help", "show this help") { todo = :help }

  parser.separator("options")

  parser.on("-H HOST", "--host HOST", "set the forwarding host") { |host| forwarding_host? = host }
end

parser.parse!

case todo
when :version
  puts Doppel::VERSION
when :help
  puts(parser)
end

unless forwarding_host?
  puts("forwarding host must be set")
  exit(1)
end

Doppel::Interceptor.new(forwarding_host?.as(String))
