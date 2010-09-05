require 'rubygems'

root_dir = File.dirname(__FILE__)
if File.directory?(File.join(root_dir,'.git'))
  Dir.chdir(root_dir) do |path|
    require 'bundler'

    begin
      Bundler.setup(:default)
    rescue Bundler::BundlerError => e
      STDERR.puts e.message
      STDERR.puts "Run `bundle install` to install missing gems"
      exit e.status_code
    end
  end
end

lib_dir = File.join(root_dir,'lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'ronin/ui/web/team/app'

run Ronin::UI::Web::Team::App
