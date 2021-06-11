lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codemonitor/version'

Gem::Specification.new do |spec|
  spec.name          = 'codemonitor'
  spec.version       = CodeMonitor::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.6.0'
  spec.authors       = ['Ferran Basora']
  spec.email         = ['fcsonline@gmail.com']

  spec.summary       = 'Collect many metrics your code is generating'
  spec.description   = <<-DESCRIPTION
    CodeMonitor collects many metrics your code is generating
  DESCRIPTION

  spec.homepage      = 'https://rubygems.org/gems/codemonitor'
  spec.license       = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/fcsonline/codemonitor',
    'bug_tracker_uri' => 'https://github.com/fcsonline/codemonitor/issues'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extra_rdoc_files = ['LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dogapi', '~> 1.45'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'pry', '~> 0.13.1'
  spec.add_development_dependency 'rubocop', '~> 0.80'
end
