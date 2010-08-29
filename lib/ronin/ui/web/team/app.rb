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

require 'ronin/ui/web/team/helpers'
require 'ronin/ui/output/helpers'
require 'ronin/version'

require 'sinatra'
require 'faye'
require 'set'

module Ronin
  module UI
    module Web
      module Team
        class App < Sinatra::Base

          set :run, true
          set :root, File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','data','ronin','team'))

          enable :sessions
          use Faye::RackAdapter, :mount => '/share', :timeout => 20

          helpers Team::Helpers
          helpers UI::Output::Helpers

          configure do
            @@users = Set[]
            
            trap(:INT) do
              env['faye.client'].publish('/sysmsg', {:msg => "Server Restarting... Please Wait."})
            end
            
          end

          before  do
            if no_session?
              unless %w[/ /intro /setup /login].include?(request.path)
                redirect '/setup'
              end
            end
          end

          get '/' do
            if seen_intro?
              if has_session?
                redirect '/chat'
              else
                redirect '/setup'
              end
            else
              redirect '/intro'
            end
          end

          get '/intro' do
            session[:seen_intro] = true
            erb :intro, :layout => false
          end

          get '/login' do
            
            if no_session?
              username = params[:username]

              if username.empty?
                redirect '/setup'
              end

              if @@users.include?(username)
                print_info "User #{username.dump} is already logged in."

                redirect '/setup'
              end

              print_info "User #{username.dump} logged in."

              session[:username] = username
              session[:ipaddr] = env['REMOTE_ADDR']
              session[:agent] = env['HTTP_USER_AGENT']
              session[:lang] = env['HTTP_ACCEPT_LANGUAGE']

              env['faye.client'].publish('/sysmsg', {:msg =>  "#{username} joined the chat."})
              @@users << username
            end
            redirect '/chat'
          end

          get '/setup' do
            erb :setup
          end

          get '/chat' do
            erb :chat
          end

          get '/console' do
            erb :console
          end

          get %r{/docs/([A-Za-z0-9:]+)(/(class|instance)_method/(.+))?} do
            @class_name = params[:captures][0]
            @url_path = @class_name.split('::').join('/')

            if params[:captures][1]
              scope = params[:captures][2]
              method = params[:captures][3]

              @url_fragment = "##{method}-#{scope}_method"
            end

            file_name = File.join('lib',@class_name.to_const_path) + '.rb'

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
            env['faye.client'].publish('/ls', {:data => `nmap 127.0.0.1` }) if has_session?
            ""
          end

        end
      end
    end
  end
end
