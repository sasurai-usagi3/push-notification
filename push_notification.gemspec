lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'push_notification/version'

Gem::Specification.new do |spec|
  spec.name          = 'push_notification'
  spec.version       = PushNotification::VERSION
  spec.authors       = ['Takumu Uyama']
  spec.email         = ['sasurai.usagi3@gmail.com']

  spec.summary       = 'Gem for push notification'
  spec.description   = 'Use this gem, you can send push notification to browser simply'
  spec.homepage      = 'https://github.com/sasurai-usagi3/push-notification'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'jwt'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
