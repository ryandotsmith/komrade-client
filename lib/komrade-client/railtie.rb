module Komrade
  class Railtie < Rails::Railtie
    railtie_name :komrade_client

    rake_tasks do
      load "#{File.dirname(__FILE__)}/tasks.rb"
    end
  end
end
