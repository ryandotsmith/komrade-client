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
    #
    # Before the worker evaluates the code extracted from the job,
    # it spawns a thread which will send heartbeats to komrade. This
    # indicates to the back end that the job is being processed. If heartbeats
    # stop coming in for a job, komrade may thing that the job is lost and
    # subsequently release the lock and place it back in the queue.
    def work
      jobs = Queue.dequeue
      until jobs.empty?
        job = jobs.pop
        begin
          log(:at => "work-job", :id => job['id']) do
            @finished, @beats = false, 0
            Thread.new do
              while @beats == 0 || !@finished
                @beats += 1
                log(:at => "heartbeat-job", :id => job['id'])
                HttpHelpers.post("/jobs/#{job['id']}/heartbeats")
                sleep(1)
              end
            end
            call(job["payload"])
            @finished = true
          end
        rescue => e
          handle_failure(job, e)
          raise(e)
        ensure
          Queue.remove(job["id"])
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
      log(:at => "handle-failure", :id => job['id'], 'failure-id' => fid)
      b = {error: e.class, message: e.message}
      HttpHelpers.put("/jobs/#{job['id']}/failures/#{fid}", b)
    end

    def log(data, &blk)
      Komrade.log(data, &blk)
    end

  end
end
