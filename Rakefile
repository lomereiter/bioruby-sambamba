# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bio-sambamba"
  gem.homepage = "http://github.com/lomereiter/bioruby-sambamba"
  gem.license = "MIT"
  gem.summary = %Q{Ruby wrapper for Sambamba tool}
  gem.description = %Q{New Sambamba library comes with a command-line tool for working with SAM/BAM files. This gem brings some of its functionality to Ruby.}
  gem.email = "lomereiter@gmail.com"
  gem.authors = ["Artem Tarasov"]
  # dependencies defined in Gemfile

  gem.files.include "lib/bio-sambamba/*.rb"
  gem.files.include "lib/bio-sambamba.rb"
end
Jeweler::RubygemsDotOrgTasks.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |features|
end

task :test => :cucumber

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bio-sambamba #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
