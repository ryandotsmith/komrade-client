task :environment

namespace :komrade do
  desc "Start a new worker."
  task :work  => :environment do
    trap('INT') {exit}
    trap('TERM') {@worker.stop}
    @worker = Komrade::Worker.new
    @worker.start
  end

  desc "Returns the number of jobs in the (default or QUEUE) queue"
  task :count => :environment do
    $stdout.puts(Komrade::Worker.new.queue.count)
  end
end
