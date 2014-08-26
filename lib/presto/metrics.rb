require "presto/metrics/version"
require 'httparty'
require 'json'

module Presto
  module Metrics
  	class Client 
	  	def initialize(opts={})
 			@host = opts[:host] || "localhost"
  			@port = opts[:port] || "8080"
		 	@endpoint = opts[:endpoint] || "http://#{@host}:#{@port}"
		end

		def get(mbean)
			resp = HTTParty.get("#{@endpoint}/v1/jmx/mbean/#{mbean}")
			json = JSON.parse(resp.body)
			json
	  	end
  	end 
  end
end

