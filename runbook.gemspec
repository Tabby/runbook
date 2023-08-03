lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'runbook/version'

Gem::Specification.new do |spec|
  spec.name          = 'runbook'
  spec.version       = Runbook::VERSION
  spec.authors       = ['pblesi']
  spec.email         = ['code@getbraintree.com']

  spec.summary       = 'Write beautiful, executable runbooks for conducting system operations.'
  spec.description   = 'Runbook provides a DSL for specifying system operations. This DSL is used to generate ' \
                       'formatted runbooks as well as interactive runbooks to be executed on the command line.'
  spec.homepage      = 'https://github.com/braintree/runbook/'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org/'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 5.0.1.x'
  spec.add_runtime_dependency 'airbrussh', '~> 1.4.1'
  spec.add_runtime_dependency 'method_source', '~> 1.0'
  spec.add_runtime_dependency 'sshkit', '1.21.5'
  spec.add_runtime_dependency 'sshkit-sudo', '~> 0.1'
  spec.add_runtime_dependency 'thor', '~> 1.2.2'
  spec.add_runtime_dependency 'tty-progressbar', '~> 0.18.2'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.23.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
