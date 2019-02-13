require "option_parser"
require "./doppel"

parser = OptionParser.new do |parser|
  parser.banner = "usage: doppel"

  parser.on("-v", "--version", "display the version") { puts Doppel::VERSION; exit 0 }
  parser.on("-h", "--help", "show this help") { puts parser; exit 0 }
end

parser.parse!
