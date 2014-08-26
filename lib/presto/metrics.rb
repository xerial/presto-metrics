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
			JSON.parse(resp.body)
	  	end

	  	def get_attributes(mbean) 
			json = get(mbean)
			json['attributes'] || []
	  	end

	  	def get_attribute(mbean, attr_name) 
			get_attributes(mbean).find {|obj| obj['name'] == attr_name } || {}
	  	end

	  	def get_metrics(mbean) 
	  		kv = Hash.new
	  		get_attributes(mbean)
	  		 	.reject {|attr| attr['name'].nil? || attr['value'].nil? }
	  		 	.each { |attr|
	  		 		kv[attr['name']] = attr['value']
	  		  	}
	  		kv
	  	end

	  	def memory_usage_metrics
	  		get_metrics("java.lang:type=Memory")
	  	end

	  	def query_manager_metrics
	  		get_metrics("com.facebook.presto.execution:name=QueryManager")
	  	end

	  	def query_execution_metrics
	  		get_metrics("com.facebook.presto.execution:name=QueryExecution")
	  	end

	  	def node_scheduler_metrics
	  		get_metrics("com.facebook.presto.execution:name=NodeScheduler")
	  	end

	  	def task_executor_metrics
	  		get_metrics("com.facebook.presto.execution:name=TaskExecutor")
	  	end

	  	def task_manager_metrics
	  		get_metrics("com.facebook.presto.execution:name=TaskManager")
	  	end

  	end 
  end
end

