require 'parallel'
require 'thread'
require 'concurrent'

class MapAhead
  def stream_map enumerable, work_ahead=1, &blk
    return enumerable if blk.nil?
    Enumerator.new do |y|
      pool = Concurrent::FixedThreadPool.new(work_ahead)
      results = Queue.new
      work_ahead.times do
        work = enumerable.next
        puts "adding: #{work}"
        pool.post do
          puts "working: #{work}"
          results << blk.call(work)
        end
      end
      while !pool.shutdown? || !results.empty?
        puts "waiting"
        begin
          puts "popping"
          y << results.pop(true)
          work = enumerable.next
          puts "adding2: #{work}"
          pool.post do
            puts "working2: #{work}"
            results << blk.call(work)
          end
        rescue ThreadError
          nil
        rescue StopIteration
          pool.shutdown
        end
      end
    end
  end
end
