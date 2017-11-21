playing around with mapping a stream (enumerable)
while working items ahead of current read point

this example will end up calling sleep in parallel x2
```
enum = Enumerator.new { |y| 10.times { |i| y << i } }
enum = MapAhead.stream_map(enum, 2) { sleep 1 }
enum.each do |r|
  puts r
end
```

see readme
