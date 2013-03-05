require 'komrade-client/dispatcher'
require 'komrade-client/queue'

task :environment

namespace :komrade do
  desc "Start a new worker."
  task :work  => :environment do
    trap('INT') {Komrade::Dispatcher.stop}
    trap('TERM') {exit}
   Komrade::Dispatcher.start(ENV['threads'])
  end

  desc "Deletes all jobs in the queue."
  task :delete_all => :environment do
    $stdout.puts(Komrade::Queue.delete_all)
  end
end
