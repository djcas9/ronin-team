# -*- encoding: utf-8 -*-

begin
  Ore::Specification.new do |gemspec|
    # custom logic here
  end
rescue NameError
  STDERR.puts "The 'ronin-team.gemspec' file requires Ore."
  STDERR.puts "Run `gem install ore` to install Ore."
end
