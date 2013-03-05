require 'thread'
require 'komrade-client/worker'
require 'komrade-client/queue'

module Komrade
  module Dispatcher
    extend self
    @running = true
    @workers = []
    @threads = []
    @pending = ::Queue.new

    # Start a loop and work jobs indefinitely.
    # Call this method to start the worker.
    # This is the easiest way to start working jobs.
    def start(num_threads=4)
      Komrade.log(:at => "Starting komrade worker.", :num_threads => num_threads)
      @producer = Thread.new do
        while @running
          Queue.dequeue(:limit => num_threads).each do |job|
            @pending << job
          end
        end
      end

      num_threads.times.map do
        w = Worker.new(@pending)
        @workers << w
        w.start.tap {|t| @threads << t}
      end.map(&:join)
    end

    def stop
      @running = false
      @producer.kill
      @workers.each(&:stop)
      @threads.each(&:kill)
    end

  end
end
