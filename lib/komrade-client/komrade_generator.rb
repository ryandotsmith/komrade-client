class KomradeGenerator < Rails::Generators::Base
  def create_procfile
    create_file "Procfile", "web: bundle exec rails s\nworker: bundle exec rake komrade:work"
  end

  def add_gem
    gem "komrade-client"
  end
end
