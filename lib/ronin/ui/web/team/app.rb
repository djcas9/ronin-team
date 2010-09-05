#
# Ronin Team - Real-Time Security Research
#
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com),
#                    Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/ui/web/team/warden'
require 'ronin/ui/web/team/helpers'
require 'ronin/ui/output/helpers'
require 'ronin/support/inflector'
require 'ronin/database/migrations/team'
require 'ronin/database'
require 'ronin/version'

require 'set'
require 'uuidtools'
require 'dm-serializer'
require 'sinatra'
require 'sinatra_warden'
require 'faye'

module Ronin
  module UI
    module Web
      module Team
        class App < Sinatra::Base

          set :run, true
          set :root, File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','data','ronin','team'))

          enable :sessions

          use Warden::Manager do |manager|
            manager.default_strategies :password
            manager.failure_app = App
          end

          register Sinatra::Warden

          set :auth_success_path, '/sessions/new'
          set :auth_failure_path, '/login'
          set :auth_use_erb, true

          use Faye::RackAdapter, :mount => '/share', :timeout => 20

          helpers Team::Helpers
          helpers UI::Output::Helpers

          configure do
            @@users = Set[]
            
            Database.setup
          end

          before  do
            unless seen_intro?
              redirect '/intro' unless request.path == '/intro'
            end
          end

          get '/' do
            redirect '/chat'
          end

          get '/intro' do
            session[:seen_intro] = true

            erb :intro, :layout => false
          end

          get '/sessions/new' do
            authorize!

            unless @@users.include?(user.name)
              print_info "User #{user.name.dump} logged in."
              @@users << user.name
            end

            redirect '/chat'
          end

          get '/sessions/destroy' do
            authorize!

            print_info "User #{user.name.dump} logging out ..."
            @@users.delete(user.name)

            faye.publish('/announce', {})
            redirect '/logout'
          end
          
          get '/chat' do
            authorize!

            erb :chat
          end

          get '/console' do
            authorize!

            erb :console
          end

          get '/campaigns' do
            json Campaign.all
          end

          get '/campaigns/:id' do
            json Campaign.get(params[:id])
          end

          get '/campaigns/:id/addresses' do
            json Address.all(:campaign => params[:id])
          end

          get '/campaigns/:id/mac_addresses' do
            json MACAddress.all(:campaign => params[:id])
          end

          get '/campaigns/:id/ip_addresses' do
            json IPAddress.all(:campaign => params[:id])
          end

          get '/campaigns/:id/host_names' do
            json HostName.all(:campaign => params[:id])
          end

          get '/campaign/:id/urls' do
            json URL.all('host_name.campaign' => params[:id])
          end

          get '/addresses/:id' do
            json Address.get(:id)
          end

          get '/mac_addresses/:id' do
            json IPAddress.get(:id)
          end

          get '/ip_addresses/:id' do
            json IPAddress.get(:id)
          end

          get '/host_names/:id' do
            json IPAddress.get(:id)
          end

          get '/urls/:id' do
            json URL.get(:id)
          end

          get %r{/docs/([A-Za-z0-9:]+)(/(class|instance)_method/(.+))?} do
            @class_name = params[:captures][0]
            @url_path = @class_name.gsub(/::/,'/')

            if params[:captures][1]
              scope = params[:captures][2]
              method = params[:captures][3]

              @url_fragment = "##{method}-#{scope}_method"
            end

            file_name = File.join('lib',Support::Inflector.underscore(@class_name) + '.rb')

            name, gem = Installation.gems.find do |name,gem|
              gem.files.include?(file_name)
            end

            if name
              redirect "http://yardoc.org/docs/ronin-ruby-#{name}/#{@url_path}.html#{@url_fragment}"
            else
              erb :docs_not_found
            end
          end


          get '/ls' do
            authorize!

            faye.publish('/sysmsg', {:message => `nmap 127.0.0.1` }) if has_session?
            ""
          end

        end
      end
    end
  end
end
