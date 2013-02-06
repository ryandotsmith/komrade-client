require 'uri'

module Komrade
  extend self
  Error = Class.new(StandardError)

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
      data.merge!(val: (Time.now - start))
    end
    data.reduce(out=String.new) do |s, tup|
      s << [tup.first, tup.last].join("=") << " "
    end
    $stdout.puts(out)
    return result
  end

end

require 'komrade-client/queue'

if defined?(Rails)
  require 'komrade-client/railtie'
  require 'komrade-client/komrade_generator'
end
