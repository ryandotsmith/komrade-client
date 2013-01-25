require 'komrade'
require 'komrade/http_helpers'

module Komrade
  module Queue
    extend self
    extend HttpHelpers

    def enqueue(opts)
      queue = opts[:queue]
      method = opts[:method]
      args = *opts[:args]
      if method.nil?
        raise(ArgumentError, "Must include method to enqueue.")
      end
      if queue
        post("/queues/#{queue}", method: method, args: args)
      else
        post("/queues", method: method, args: args)
      end
    end

    def dequeue(opts)
      limit = opts[:limit] || 1
      queue = opts[:queue]
      if queue
        get("/queues/#{queue}/jobs?limit=#{limit}")
      else
        get("/queues/jobs?limit=#{limit}")
      end
    end

    def delete(id)
      delete("/jobs/#{id}")
    end
  end
end
