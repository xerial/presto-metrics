module Presto
  module Metrics

    class Client
      def initialize(opts={})
        require 'httparty'
        require 'json'
        require 'set'
        require 'time'

        @host = opts[:host] || 'localhost'
        @port = opts[:port] || '8080'
        @endpoint = opts[:endpoint] || "http://#{@host}:#{@port}"
        @mbean_path = opts[:mbean_path] || '/v1/jmx/mbean'
        @query_path = opts[:query_path] || '/v1/query'
        @node_path = opts[:node_path] || '/v1/node'
        @caml_case = opts[:caml_case] || false
      end

      @@MBEAN_ALIAS = {
          'memory' => 'java.lang:type=Memory',
          'gc_cms' => 'java.lang:type=GarbageCollector,name=ConcurrentMarkSweep',
          'gc_parnew' => 'java.lang:type=GarbageCollector,name=ParNew',
          'os' => 'java.lang:type=OperatingSystem',
          'query_manager' => 'com.facebook.presto.execution:name=QueryManager',
          'query_execution' => 'com.facebook.presto.execution:name=QueryExecution',
          'node_scheduler' => 'com.facebook.presto.execution:name=NodeScheduler',
          'task_executor' => 'com.facebook.presto.execution:name=TaskExecutor',
          'task_manager' => 'com.facebook.presto.execution:name=TaskManager'
      }

      def path(path)
        c = path.split(/:/)
        target = c[0]
        mbean = @@MBEAN_ALIAS[target] || target
        json_obj = get_metrics(mbean)
        return json_obj if c.size <= 1
        query_list = (c[1] || '').split(/,/)
        result = {}
        query_list.each { |q|
          path_elems = q.split('/')
          target_elem = extract_path(json_obj, path_elems, 0)
          result[q] = target_elem unless target_elem.nil?
        }
        result
      end

      def extract_path(json_obj, path, depth)
        return nil if json_obj.nil?
        if depth >= path.length
          json_obj
        else
          if json_obj.kind_of?(Array)
            # Handle key, value pairs of GC information
            value = json_obj.find { |e|
              e.is_a?(Hash) && e['key'] == path[depth]
            }
            extract_path(value['value'], path, depth+1)
          else
            extract_path(json_obj[path[depth]], path, depth+1)
          end
        end
      end

      def query
        Query.new(self)
      end

      def get_mbean(mbean)
        JSON.parse(get_mbean_json(mbean))
      end

      def get(path, default='{}')
        resp = HTTParty.get("#{@endpoint}#{path}")
        if resp.code == 200
          resp.body
        else
          default
        end
      end

      def get_mbean_json(mbean)
        get("#{@mbean_path}/#{mbean}")
      end

      def get_query_json(path='', default='[]')
        get("#{@query_path}/#{path}", default)
      end

      def get_node_json
        get(@node_path)
      end

      def get_attributes(mbean)
        json = get_mbean(mbean)
        json['attributes'] || []
      end

      def get_attribute(mbean, attr_name)
        get_attributes(mbean).find { |obj| obj['name'] == attr_name } || {}
      end

      def map_to_canonical_name(name_arr)
        name_arr.map { |name| to_canonical_name(name) }
      end

      def to_canonical_name(name)
        name.to_s.downcase.gsub(/_/, '')
      end

      def underscore(str)
        str.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr('-', '_').
            downcase
      end

      def get_metrics(mbean, target_attr=[])
        kv = Hash.new
        arr = target_attr.kind_of?(Array) ? target_attr : [target_attr]
        c_target_attr = map_to_canonical_name(arr).to_set
        get_attributes(mbean)
            .reject { |attr| attr['name'].nil? || attr['value'].nil? }
            .each { |attr|
          c_name = to_canonical_name(attr['name'])
          if c_target_attr.empty? || c_target_attr.include?(c_name)
            key = @caml_case ? attr['name'] : underscore(attr['name'])
            kv[key] = attr['value']
          end
        }
        kv
      end

      def memory_usage_metrics(target_attr=[])
        get_metrics('java.lang:type=Memory', target_attr)
      end

      def gc_cms_metrics(target_attr=[])
        get_metrics('java.lang:type=GarbageCollector,name=ConcurrentMarkSweep', target_attr)
      end

      def gc_parnew_metrics(target_attr=[])
        get_metrics('java.lang:type=GarbageCollector,name=ParNew', target_attr)
      end

      def gc_g1_metrics(target_attr=[])
        get_metrics('java.lang:type=GarbageCollector,name=G1', target_attr)
      end

      def os_metrics(target_attr=[])
        get_metrics('java.lang:type=OperatingSystem', target_attr)
      end

      def query_manager_metrics(target_attr=[])
        get_metrics('com.facebook.presto.execution:name=QueryManager', target_attr)
      end

      def query_execution_metrics(target_attr=[])
        get_metrics('com.facebook.presto.execution:name=QueryExecution', target_attr)
      end

      def node_scheduler_metrics(target_attr=[])
        get_metrics('com.facebook.presto.execution:name=NodeScheduler', target_attr)
      end

      def task_executor_metrics(target_attr=[])
        get_metrics('com.facebook.presto.execution:name=TaskExecutor', target_attr)
      end

      def task_manager_metrics(target_attr=[])
        get_metrics('com.facebook.presto.execution:name=TaskManager', target_attr)
      end

      def node_metrics(target_attr=[])
        p = URI::Parser.new
        node_state = JSON.parse(get_node_json)
        node_state.map{|n|
          uri = n['uri'] || ''
          m = {}
          m['host'] = p.parse(uri).host
          n.each{|k, v|
            key = @caml_case ? k : underscore(k)
            m[key] = v
          }
          m
        }
      end

      private :map_to_canonical_name, :to_canonical_name, :underscore
    end
  end
end

