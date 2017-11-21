require 'parallel'
require 'thread'
require 'concurrent'

class MapAhead
  def stream_map enumerable, work_ahead=1, &blk
    return enumerable if blk.nil?
    Enumerator.new do |y|
      pool = Concurrent::FixedThreadPool.new(work_ahead)
      results = Queue.new
      enumerable.first(work_ahead).each do |i|
        pool.post do
          results << blk.call(i)
        end
      end
      pool.shutdown
      while !pool.shutdown? || !results.empty?
        begin
          y << results.pop(true)
          pool.post do
            results << blk.call(enumerable.next)
          end
        rescue ThreadError
          nil
        end
      end
    end
  end
end
