require "presto/metrics/client"
require 'pp'

module Presto
  module Metrics



  	class Query 
  		def initialize(client)
  			@client = client
  		end

  		def format_table(tbl) 
  			# Compute col length
  			col = {}
  			tbl.each{|row|
  				row.each_with_index {|cell, i| 
  					l = cell.size
  					col[i] ||= l
  					col[i] = [[col[i], l].max, 200].min
  				}
  			}
  			tbl.each{|row|
  				line = []
  				row.each_with_index{|cell, i|
  					line << cell[0..col[i]].ljust(col[i])
  				}
  				puts line.join("\t")
  			}
  			0
  		end

	  	def list
	  		ql = query_list
	  		tbl = ql.map {|q|
	  			s = q['session'] || {}
	  			query = q['query'].gsub(/[\t\r\n]/, " ").gsub(/ {1,}/, " ").strip
	  			[q['queryId'], q['elapsedTime'], q['state'], s['user'], s['catalog'], s['schema'], s['source'], query]
	  		}
	  		format_table tbl
	  	end

	  	def find(id)
	  		JSON.parse(@client.get_query_json(id, "{}"))
	  	end

	  	def query_list(path="")
	  		JSON.parse(@client.get_query_json(path))
	  	end

	  	def metrics 
	  		ql = query_list
	  		ql.map{|qi|
	  			h = {}
	  			h['query_id'] = qi['queryId'] || ""
	  			h['state'] = qi['state'] || ""
	  			session = qi['session'] || {}
	  			h['source'] = session['source'] || ""
	  			h['user'] = session['user'] || h['source'].gsub(/[^a-zA-Z0-9]/,'')
	  			h['running_drivers'] = qi['runningDrivers'] || 0
	  			h['queued_drivers'] = qi['queuedDrivers'] || 0
	  			h['completed_drivers'] = qi['completedDrivers'] || 0
	  			h['total_drivers'] = qi['totalDrivers'] || 0
	  			h['elapsed_time'] = qi['elapsedTime'] || "0.0m"
	  			h['create_time'] = qi['createTime']
	  			h['running_time'] = qi['endTime'] || Time.now.utc.iso8601(3)
	  			#if(h['state'] == "FAILED")
	  			#	h['errorCode'] = find(h['query_id'])['errorCode'] || {}
	  			#end
	  			h
	  		}
	  	end

  	end
  end
end