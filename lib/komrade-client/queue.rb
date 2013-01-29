require 'securerandom'
require 'komrade-client'
require 'komrade-client/http_helpers'

module Komrade
  module Queue
    extend self
    extend HttpHelpers

    def enqueue(method, *args)
      SecureRandom.uuid.tap do |id|
        put("/jobs/#{id}", method: method, args: args)
        log(:at => "enqueue-job", :job => id, :method => method)
      end
    end

    def dequeue(opts={})
      limit = opts[:limit] || 1
      get("/jobs?limit=#{limit}")
    end

    def remove(id)
      delete("/jobs/#{id}")
    end

    def log(data)
      Komrade.log(data)
    end
  end
end
