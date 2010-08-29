require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:development, :doc)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'
require './lib/ronin/team/version.rb'

Jeweler::Tasks.new do |gem|
  gem.name = 'ronin-team'
  gem.version = Ronin::Team::VERSION
  gem.license = 'GPL-2'
  gem.summary = %Q{Real-Time Security Research}
  gem.description = %Q{Ronin Team is a real-time web application, designed to help Security Researchers collaborate.}
  gem.email = %w[dustin.webber@gmail.com postmodern.mod3@gmail.com]
  gem.homepage = 'http://github.com/mephux/ronin-team'
  gem.authors = ['Dustin Willis Webber', 'Postmodern']
  gem.has_rdoc = 'yard'
end
Jeweler::GemcutterTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
