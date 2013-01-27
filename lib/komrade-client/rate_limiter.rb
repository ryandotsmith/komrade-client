module Komrade
  module RateLimiter
    extend self

    Unavailable = Class.new(Komrade::Error)

    def limits
      @limits ||= {counts: Hash.new(0), timestamps: Hash.new(0)}
    end

    def breaks
      @breaks ||= {counts: Hash.new(0), timestamps: Hash.new(0)}
    end

    def stamp(data, attr, bucket)
      timestamp = Time.now.to_i / bucket
      data[:counts][attr] = 0 unless data[:timestamps][attr] == timestamp
      timestamp
    end

    def increment(data, attr, timestamp)
      data[:timestamps][attr] = timestamp
      data[:counts][attr] += 1
    end

    def check(data, attr, value, &blk)
      if value == 0 || data[:counts][attr] < value
        yield
      else
        raise(Unavailable, attr)
      end
    end

    def limiter(attr, value, bucket, &blk)
      timestamp = stamp(limits, attr, bucket)
      increment(limits, attr, timestamp)
      check(limits, attr, value) do
        yield
      end
    end

    def breaker(attr, value, bucket, &blk)
      timestamp = stamp(breaks, attr, bucket)
      check(breaks, attr, value) do
        begin
          yield
        rescue => e
          increment(breaks, attr, timestamp)
          raise
        end
      end
    end

  end
end
