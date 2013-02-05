require 'securerandom'
require 'komrade-client'
require 'komrade-client/http_helpers'

module Komrade
  module Queue
    extend self
    extend HttpHelpers

    # Generates a UUID for the job and sends it to komrade.
    #
    # Fast operation.
    def enqueue(method, *args)
      SecureRandom.uuid.tap do |id|
        log(:at => "enqueue-job", :job => id, :method => method) do
          put("/jobs/#{id}", method: method, args: args)
        end
      end
    end

    # The jobs that are returned will be locked in komrade.
    # This ensures that no other komrade clients can view them.
    # If you dequeue a job, it is your responsiblity to update the job.
    # Updates to jobs include: heartbeat, fail, and delete.
    #
    # There is no logging for dequeue since this method will be called
    # frequently. Instead, logging should happen in the caller of
    # dequeue to inform the stream that a job was locked.
    #
    # Moderately fast operation.
    def dequeue(opts={})
      limit = opts[:limit] || 1
      get("/jobs?limit=#{limit}")
    end

    # Idempotent call to delete a job from the queue.
    #
    # Fast operation.
    def remove(id)
      log(:at => "remove-job", :job => id) do
        delete("/jobs/#{id}")
      end
    end

    # Delete all of the jobs in a queue.
    # Returns the count of the jobs that were deleted.
    #
    # Slow operation.
    def delete_all
      log(:at => "delete-all") do
        post("/delete-all-jobs")
      end
    end

    private

    def log(data, &blk)
      Komrade.log(data, &blk)
    end
  end
end
