require "option_parser"
require "./doppel"

parser = OptionParser.new do |parser|
  parser.banner = "usage: doppel"

  parser.on("-v", "--version", "display the version") { puts Doppel::VERSION; exit 0 }
  parser.on("-h", "--help", "show this help") { puts parser; exit 0 }

  parser.separator

  parser.on("-i", "--intercept", "Enter intercept mode") { Doppel.intercept; exit 0 }
  parser.on("-p", "--playback", "Enter playback mode") { Doppel.playback; exit 0 }
end

parser.parse!

puts parser; exit 0
