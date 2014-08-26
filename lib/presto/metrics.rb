require "presto/metrics/version"
require 'httparty'
require 'json'

module Presto
  module Metrics

  	class Client 
		private :map_to_canonical_name, :to_canonical_name, :underscore

	  	def initialize(opts={})
 			@host = opts[:host] || "localhost"
  			@port = opts[:port] || "8080"
		 	@endpoint = opts[:endpoint] || "http://#{@host}:#{@port}"
		 	@mbean_path = opts[:mbean_path] || "/v1/jmx/mbean/"
		 	@caml_case = opts[:caml_case] || false
		end

		def get(mbean)
			JSON.parse(get_json(mbean))
	  	end

	  	def get_json(mbean) 
			resp = HTTParty.get("#{@endpoint}#{@mbean_path}#{mbean}")
			resp.body
	  	end 

	  	def get_attributes(mbean) 
			json = get(mbean)
			json['attributes'] || []
	  	end

	  	def get_attribute(mbean, attr_name) 
			get_attributes(mbean).find {|obj| obj['name'] == attr_name } || {}
	  	end



	  	def map_to_canonical_name(name_arr) 
	  		name_arr.map{|name| to_canonical_name(name)	}
		end

		def to_canonical_name(name) 
	  		name.to_s.downcase.gsub(/_/, "")
	  	end

  	    def underscore(str)
	    	str.gsub(/::/, '/').
		    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
	    	gsub(/([a-z\d])([A-Z])/,'\1_\2').
		    tr("-", "_").
		    downcase
		end

	  	def get_metrics(mbean, target_attr=[]) 
	  		kv = Hash.new
	  		arr = target_attr.kind_of?(Array) ? target_attr : [target_attr]
	  		c_target_attr = map_to_canonical_name(arr).to_set
	  		get_attributes(mbean)
	  		 	.reject {|attr| attr['name'].nil? || attr['value'].nil? }
	  		 	.each {|attr| 
	  		 		c_name = to_canonical_name(attr['name'])
	  		 		if c_target_attr.empty? || c_target_attr.include?(c_name)
	  		 			key = @caml_case ? attr['name'] : underscore(attr['name']).to_sym 
	  		 			kv[key] = attr['value'] 
	  		 		end
	  		 	}
	  		kv
	  	end

	  	def memory_usage_metrics(target_attr=[])
	  		get_metrics("java.lang:type=Memory", target_attr)
	  	end

	  	def gc_cms_metrics(target_attr=[])
	  		get_metrics("java.lang:type=GarbageCollector,name=ConcurrentMarkSweep", target_attr)
	  	end

	  	def gc_parnew_metrics(target_attr=[])
	  		get_metrics("java.lang:type=GarbageCollector,name=ParNew", target_attr)
	  	end

	  	def os_metrics(target_attr=[])
	  		get_metrics("java.lang:type=OperatingSystem", target_attr)
	  	end

	  	def query_manager_metrics(target_attr=[])
	  		get_metrics("com.facebook.presto.execution:name=QueryManager", target_attr)
	  	end

	  	def query_execution_metrics(target_attr=[])
	  		get_metrics("com.facebook.presto.execution:name=QueryExecution", target_attr)
	  	end

	  	def node_scheduler_metrics(target_attr=[])
	  		get_metrics("com.facebook.presto.execution:name=NodeScheduler", target_attr)
	  	end

	  	def task_executor_metrics(target_attr=[])
	  		get_metrics("com.facebook.presto.execution:name=TaskExecutor", target_attr)
	  	end

	  	def task_manager_metrics(target_attr=[])
	  		get_metrics("com.facebook.presto.execution:name=TaskManager", target_attr)
	  	end

  	end 
  end
end

