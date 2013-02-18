require 'uri'
require 'thread'

module Komrade
  extend self
  Error = Class.new(StandardError)
  outLocker = Mutex.new

  def env(key)
    ENV[key]
  end

  def env!(key)
    env(key) || raise(Error, "Komrade requires #{key} be set in the ENV.")
  end

  def url
    URI.parse(env!("KOMRADE_URL"))
  end

  def log(data)
    data.merge!(:lib => 'komrade-client')
    result = nil
    if data.key?(:measure)
      data[:measure].insert(0, "komrade.")
    end
    if block_given?
      start = Time.now
      result = yield
      data.merge!(:val => (Time.now - start))
    end
    data.reduce(out=String.new) do |s, tup|
      s << [tup.first, tup.last].join("=") << " "
    end
    outLocker.synchronize do
      $stdout.puts(out)
    end
    return result
  end

end

require 'komrade-client/queue'

if defined?(Rails)
  require 'rails/railtie'
  require 'komrade-client/railtie'

  require 'rails/generators/base'
  require 'komrade-client/komrade_generator'
end
