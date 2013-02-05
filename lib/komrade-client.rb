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

  def pem
    @pem ||= File.join(File.dirname(__FILE__), "../service-1.komrade.io.pem")
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
require 'komrade-client/railtie' if defined?(Rails)
