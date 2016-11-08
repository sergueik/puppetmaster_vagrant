# http://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024
utf8string = ''
sample = []
(1040..1071).each do |charcode|
  begin
    # NOTE: unterminated Unicode escape, does not help enclosing in try block
    # utf8string = sprintf("%s\u{0%3X}", utf8string, charcode)
  rescue
  end
end

puts "#{sample}"
puts (1040...1071).to_a.pack('U')
puts (1040..1071).to_a.pack('U*')

# "\u{0410}\u{0411}\u{0412}\u{0413}\u{0414}" 