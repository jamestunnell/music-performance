# -*- encoding: utf-8 -*-

require File.expand_path('../lib/music-performance/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "music-performance"
  gem.version       = Music::Performance::VERSION
  gem.summary       = %q{Classes for representing music notational features like pitch, note, loudness, tempo, etc.}
  gem.description   = <<DESCRIPTION
Prepare a transcribed musical score for performance by a computer.
DESCRIPTION
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@gmail.com"
  gem.homepage      = "https://github.com/jamestunnell/music-performance"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  
  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rubygems-bundler', '~> 1.4'
  gem.add_development_dependency 'rake', '~> 10.1'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  
  gem.add_dependency 'music-transcription', '~> 0.15.0'
  gem.add_dependency 'midilib', '~> 2.0'
end
