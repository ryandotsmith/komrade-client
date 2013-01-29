require 'komrade-client/queue'
require 'komrade-client/http_helpers'

module Komrade
  class Worker

    def initialize(args={})
      @running = true
    end

    # Start a loop and work jobs indefinitely.
    # Call this method to start the worker.
    # This is the easiest way to start working jobs.
    def start
      work while @running
    end

    # Call this method to stop the worker.
    # The worker may not stop immediately if the worker
    # is sleeping.
    def stop
      @running = false
    end

    # This method will lock a job & evaluate the code defined by the job.
    # Also, this method will make the best attempt to delete the job
    # from the queue before returning.
    def work
      jobs = Queue.dequeue
      until jobs.empty?
        job = jobs.pop
        begin
          call(job["payload"])
        rescue => e
          handle_failure(job, e)
        ensure
          Queue.remove(job["id"])
          log(:at => "remove-job", :job => job["id"], :method => job["payload"]["method"])
        end
      end
    end

    # Each job includes a method column. We will use ruby's eval
    # to grab the ruby object from memory. We send the method to
    # the object and pass the args.
    def call(payload)
      args = payload["args"]
      klass = eval(payload["method"].split(".").first)
      message = payload["method"].split(".").last
      klass.send(message, *args)
    end

    # This method will be called when an exception
    # is raised during the execution of the job.
    def handle_failure(job,e)
      fid = SecureRandom.uuid
      log(:at => "handle-failure", :failure_id => fid)
      b = {error: e.class, message: e.message}
      HttpHelpers.put("/jobs/#{job['id']}/failures/#{fid}", b)
    end

    def log(data)
      Komrade.log(data)
    end

  end
end
