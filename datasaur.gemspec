# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','datasaur','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'datasaur'
  s.version = Datasaur::VERSION
  s.author = 'Jeyaraj Durairaj'
  s.email = 'jeyaraj.durairaj@gmail.com'
  s.homepage = 'https://github.com/jeydurai/datasaur'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Report Generator for Cisco, Commercial Sales - India & SAARC'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','datasaur.rdoc']
  s.rdoc_options << '--title' << 'datasaur' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'datasaur'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.17.1')
end
