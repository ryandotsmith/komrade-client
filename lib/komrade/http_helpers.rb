require 'json'
require 'net/http'
require 'komrade'

module Komrade
  module HttpHelpers
    MAX_RETRY = 4

    def post(path, body)
      make_request(Net::HTTP::Post.new(path), body)
    end

    def get(path)
      make_request(Net::HTTP::Get.new(path))
    end

    def delete(path)
      make_request(Net::HTTP::Delete.new(path))
    end

    def make_request(req, body=nil)
      if body
        begin
          req.content_type = 'application/json'
          req.body = JSON.dump(body)
        rescue => e
          raise(ArgumentError,
            "Komrade is unable to convert enqueue payload to JSON.\n" +
            "payload=#{body}\n")
        end
      end
      attempts = 0
      while attempts < MAX_RETRY
        begin
          resp = http.request(req)
          if (resp.status / 100) == 2
            return JSON.parse(resp.body)
          end
        rescue => e
          puts e.backtrace
          next
        ensure
          attempts += 1
        end
      end
      raise(Komrade::Error, "Unable to connect to Komrade.")
    end

    def http
      @http ||= Net::HTTP.new(Komrade.url.to_s).tap do |h|
        if Komrade.url.scheme == 'https'
          h.use_ssl = true
          h.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end

  end
end

