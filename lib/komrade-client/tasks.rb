require 'komrade-client/worker'

task :environment

namespace :komrade do
  desc "Start a new worker."
  task :work  => :environment do
    trap('INT') {exit}
    trap('TERM') {@worker.stop}
    @worker = Komrade::Worker.new
    @worker.start
  end

  desc "Returns the number of jobs in the queue."
  task :count => :environment do
    $stdout.puts(Komrade::Worker.new.queue.count)
  end

  desc "Deletes all jobs in the queue."
  task :delete_all => :environment do
    $stdout.puts(Komrade::Worker.new.queue.delete_all)
  end
end
