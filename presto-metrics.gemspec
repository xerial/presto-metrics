# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'presto/metrics/version'

Gem::Specification.new do |spec|
  spec.name          = "presto-metrics"
  spec.version       = Presto::Metrics::VERSION
  spec.authors       = ["Taro L. Saito"]
  spec.email         = ["leo@xerial.org"]
  spec.summary       = "A library for collecting metrics of Presto, a distributed SQL engine"
  spec.description   = "Monitoring the states of Presto coordinator and worker processes through JMX REST API (/v1/jmx/mbean)"
  spec.homepage      = "https://github.com/xerial/presto-metrics"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "httparty"
end
