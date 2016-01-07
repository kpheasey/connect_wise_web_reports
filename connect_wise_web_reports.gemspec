# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'connect_wise_web_reports/version'

Gem::Specification.new do |spec|
  spec.name          = 'connect_wise_web_reports'
  spec.version       = ConnectWiseWebReports::VERSION
  spec.authors       = ['Kevin Pheasey']
  spec.email         = ['kevin@kpheasey.com']

  spec.summary       = %q{Connect Wise Web Reports API Wrapper}
  spec.description   = %q{Connect Wise Web Reports API Wrapper}
  spec.homepage      = 'https://github.com/kpheasey/connect_wise_web_reports'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'mechanize', '~> 2.7.0'
  spec.add_dependency 'nokogiri', '~> 1.6.0'
  spec.add_dependency 'plissken', '~> 0.2.0'
end
