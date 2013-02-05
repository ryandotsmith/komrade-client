require 'json'
require 'net/http'
require 'komrade-client'
require 'komrade-client/rate_limiter'

module Komrade
  module HttpHelpers
    extend self
    MAX_RETRY = 4

    def post(path, body=nil)
      make_request(Net::HTTP::Post.new(path), body)
    end

    def put(path, body=nil)
      make_request(Net::HTTP::Put.new(path), body)
    end

    def get(path)
      make_request(Net::HTTP::Get.new(path))
    end

    def delete(path)
      make_request(Net::HTTP::Delete.new(path))
    end

    def make_request(req, body=nil)
      req.basic_auth(Komrade.url.user, Komrade.url.password)
      if body
        begin
          req.content_type = 'application/json'
          req.body = JSON.dump(body)
        rescue JSON => e
          raise(ArgumentError,
            "Komrade is unable to convert enqueue payload to JSON.\n" +
            "payload=#{body}\n")
        end
      end
      attempts = 0
      while attempts < MAX_RETRY
        begin
          resp = nil
          RateLimiter.limiter(req.path, 10, 1) do
            resp = http.request(req)
          end
          if (Integer(resp.code) / 100) == 2
            return JSON.parse(resp.body)
          end
        rescue Net::HTTPError => e
          next
        rescue RateLimiter::Unavailable
          sleep(0.5)
        ensure
          attempts += 1
        end
      end
      case req.class
      when Net::HTTP::Delete
        raise(Komrade::Error, "Unable to delete work from Komrade.")
      when Net::HTTP::Put
        raise(Komrade::Error, "Unable to send work to Komrade.")
      when Net::HTTP::Get
        raise(Komrade::Error, "Unable to get work from Komrade.")
      default
        raise(Komrade::Error, "Unable to communicate with Komrade.")
      end
    end

    def http
      Net::HTTP.new(Komrade.url.host, Komrade.url.port).tap do |h|
        if Komrade.url.scheme == 'https'
          h.use_ssl = true
          h.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
      end
    end

  end
end
