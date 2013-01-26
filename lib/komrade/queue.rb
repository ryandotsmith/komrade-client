require 'securerandom'
require 'komrade'
require 'komrade/http_helpers'

module Komrade
  module Queue
    extend self
    extend HttpHelpers

    def enqueue(method, *args)
      SecureRandom.uuid.tap do |id|
        put("/jobs/#{id}", method: method, args: args)
      end
    end

    def dequeue(opts={})
      limit = opts[:limit] || 1
      get("/jobs?limit=#{limit}")
    end

    def remove(id)
      delete("/jobs/#{id}")
    end
  end
end
