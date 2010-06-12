require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "lawnchair"
    gem.summary = "Speed up your app by caching expensive code in Redis or in the ruby process itself"
    gem.description = "Fully featured caching mechanism for arbitrary pieces of resource expensive ruby code using Redis while being able to optionally store data in the Ruby process itself for maximum efficiency."
    gem.email = "shanewolf@gmail.com"
    gem.homepage = "http://github.com/gizm0duck/lawnchair"
    gem.authors = ["Shane Wolf"]
    gem.add_dependency "redis", ">=0.1.2"
    gem.add_dependency "activesupport", ">=2.3.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "lawnchair #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
