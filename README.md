# Presto::Metrics

Presto is a distributed SQL engine, which launches coordinator and worker servers to process distributed queries in a cluster. We need to monitor the states of these coordinators/workers. Presto::Metrics is a library for accessing these states from Ruby.

Presto provides REST API for accessing JMX properties. Presto::Metrics accesses this REST API to extract JMX property values.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'presto-metrics'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install presto-metrics

## Usage

```ruby

require 'presto/metrics'

client = Presto::Metrics::Client.new  # Access to http://localhost:8080 in default

# Alternatively, you can specify the host name and port number to use
client = Presto::Metrics::Client.new(:host => "localhost", :port=>8080) 


client.os_metrics
# => {:open_file_descriptor_count=>360, :max_file_descriptor_count=>10240, :committed_virtual_memory_size=>18683629568, :total_swap_space_size=>2147483648, :free_swap_space_size=>1132986368, :process_cpu_time=>240244441000, :free_physical_memory_size=>2088931328, :total_physical_memory_size=>17179869184, :system_cpu_load=>0.044989775051124746, :process_cpu_load=>0.002293214043176635, :name=>"Mac OS X", :version=>"10.9.4", :available_processors=>8, :arch=>"x86_64", :system_load_average=>2.0537109375, :object_name=>"java.lang:type=OperatingSystem"}

# This is equivalent to write as follows
client.get_metrics("java.lang:type=OperatingSystem")

# Retrieve a specific set of parameters
client.query_manager_metrics(["executor.active_count", "executor.completed_task_count"])
# => {:"executor.active_count"=>0, :"executor.completed_task_count"=>0}

client.os_metrics([:system_load_average, :free_physical_memory_size])
#=> {:free_physical_memory_size=>3690512384, :system_load_average=>2.33056640625}


# Path queries
client.path("os:physical_memory_size")
# => {"free_physical_memory_size"=>55034294272}

# You can use comma-separated list of path queries
client.path("memory:heap_memory_usage/used,non_heap_memory_usage/used")
# => {"heap_memory_usage/used"=>926714864, "non_heap_memory_usage/used"=>108948488}


# Retrieve standard metrics
client.memory_usage_metrics      # java.lang:Type=Memory
client.os_metrics                # java.lang:type=OperatingSystm
client.gc_cms_metrics            # java.lang:type=GarbageCollector,name=ConcurrentMarkSweep
client.gc_parnew_metrics         # java.lang:type=GarbageCollector,name=ParNew
client.gc_g1_metrics             # java.lang:type=GarbageCollector,name=G1 Young Generation and G1 Old Genration
client.query_manager_metrics     # com.facebook.presto.execution:name=QueryManager
client.query_execution_metrics   # com.facebook.presto.execution:name=QueryExecution
client.node_scheduler_metrics    # com.facebook.presto.execution:name=NodeScheduler
client.task_executor_metrics     # com.facebook.presto.execution:name=TaskExecutor
client.task_manager_metrics      # com.facebook.presto.execution:name=TaskManager


# Memory resource manager metrics (since Presto 0.103)
client.memory_pool_metrics
=> {"general"=>{"free_bytes"=>59700045415, "max_bytes"=>59700045415}, "reserved"=>{"free_bytes"=>2147483648, "max_bytes"=>2147483648}}

client.cluster_memory_pool_metrics
=> {"general"=>{"blocked_nodes"=>0, "free_distributed_bytes"=>116833832981, "nodes"=>4, "queries"=>8, "total_distributed_bytes"=>131855495989},
    "reserved"=>{"blocked_nodes"=>0, "free_distributed_bytes"=>15032385536, "nodes"=>4, "queries"=>0, "total_distributed_bytes"=>15032385536}}


# Retrieve presto worker metrics
pp client.node_metrics
[{"host"=>"xxx.xxx.xxx.xxx",
  "uri"=>"http://xxx.xxx.xxx.xxx:8080",
  "recent_requests"=>120.00277776491774,
  "recent_failures"=>0.0,
  "recent_successes"=>120.0027781973587,
  "last_request_time"=>"2015-03-19T03:27:23.242Z",
  "last_response_time"=>"2015-03-19T03:27:23.243Z",
  "recent_failure_ratio"=>0.0,
  "age"=>"38.56m",
  "recent_failures_by_type"=>{}},
 {"host"=>"yyy.yyy.yyy.yyy",
  "uri"=>"http://yyy.yyy.yyy.yyy:8080",
  "recent_requests"=>120.00277776491774,
  "recent_failures"=>0.0,
  "recent_successes"=>120.0027777649236,
  "last_request_time"=>"2015-03-19T03:27:23.242Z",
  "last_response_time"=>"2015-03-19T03:27:23.243Z",
  "recent_failure_ratio"=>0.0,
  "age"=>"38.56m",
  "recent_failures_by_type"=>{}}]


# Retrieve the JSON representation of JMX properties
client.get_mbean_json("java.lang:Type=Memory")

# Pretty print 
require 'pp'
pp c.memory_usage_metrics
#{
#  "verbose": false,
#  "object_pending_finalization_count": 0,
#  "heap_memory_usage": {
#    "committed": 259522560,
#    "init": 268435456,
#    "max": 14962655232,
#    "used": 84478072
#  },
#  "non_heap_memory_usage": {
#    "committed": 163250176,
#    "init": 159842304,
#    "max": 471859200,
#    "used": 53369528
3  },
#  "object_name": "java.lang:type=Memory"
#}

```

## Contributing

1. Fork it ( https://github.com/xerial/presto-metrics/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## For developers

To develop presto-metrics

```
$ bundle exec irb -I lib -r presto/metrics.rb

irb> client = Presto::Metrics::Client.new(:host => "ec2-54-205-192-36.compute-1.amazonaws.com", :port=>8080)

# reload modified code
irb> load "presto/metrics/client.rb"

```

