class KomradeGenerator < Rails::Generators::Base
  desc "This generator adds a komrade-worker process to your Procfile"
  def append_procfile
    File.open("Procfile", 'ab') do |file|
      file.write("komrade-worker: bundle exec rake komrade:work")
    end
    puts "A worker process has been added to your Procfile you will be billed accordingly."
  end
end
