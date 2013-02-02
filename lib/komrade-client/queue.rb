require 'securerandom'
require 'komrade-client'
require 'komrade-client/http_helpers'

module Komrade
  module Queue
    extend self
    extend HttpHelpers

    def enqueue(method, *args)
      SecureRandom.uuid.tap do |id|
        log(:at => "enqueue-job", :job => id, :method => method) do
          put("/jobs/#{id}", method: method, args: args)
        end
      end
    end

    def dequeue(opts={})
      limit = opts[:limit] || 1
      log(:at => "dequeue-job", :limit => limit) do
        get("/jobs?limit=#{limit}")
      end
    end

    def remove(id)
      log(:at => "remove-job", :job => id) do
        delete("/jobs/#{id}")
      end
    end

    def log(data, &blk)
      Komrade.log(data, &blk)
    end
  end
end
