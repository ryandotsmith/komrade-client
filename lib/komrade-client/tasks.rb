require 'komrade-client/worker'
require 'komrade-client/queue'

task :environment

namespace :komrade do
  desc "Start a new worker."
  task :work  => :environment do
    trap('INT') {exit}
    trap('TERM') {@worker.stop}
    @worker = Komrade::Worker.new
    @worker.start
  end

  desc "Deletes all jobs in the queue."
  task :delete_all => :environment do
    $stdout.puts(Komrade::Queue.delete_all)
  end
end
