require "option_parser"
require "./doppel"

todo = :nothing
forwarding_host? : String? = nil

parser = OptionParser.new do |parser|
  parser.banner = "usage: doppel "

  parser.on("-v", "--version", "display the version") { todo = :version }
  parser.on("-h", "--help", "show this help") { todo = :help }

  parser.separator

  parser.on("-i", "--intercept", "Enter intercept mode") { todo = :intercept }
  parser.on("-p", "--playback", "Enter playback mode") { todo = :playback }

  parser.separator("options")

  parser.on("-H HOST", "--host HOST", "set the forwarding host") { |host| forwarding_host? = host }
end

parser.parse!

case todo
when :version
  puts Doppel::VERSION
when :intercept
  unless forwarding_host?
    puts("forwarding host must be set")
    exit(1)
  end
  Doppel::Interceptor.new(forwarding_host?.as(String))
when :playback
  Doppel.playback
when :help
  puts(parser)
else
  puts(parser)
  exit 1
end
