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

require 'sinatra'
require 'faye'
require 'pp'

module Ronin
  module UI
    module Web
      module Team
        class App < Sinatra::Base

          set :run, true
          set :root, File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','data','ronin','team'))

          enable :sessions
          use Faye::RackAdapter, :mount => '/share', :timeout => 45

          before  do
          end

          helpers Team::Helpers

          get '/' do
            has_session?
            redirect '/chat'
          end

          get '/login' do
            if no_session!
              session[:username] = params[:username]
              session[:ipaddr] = env['REMOTE_ADDR']
              session[:agent] = env['HTTP_USER_AGENT']
              session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
              env['faye.client'].publish('/announce', {:newpush => true}) if has_session?
            end
            redirect '/chat'
          end

          get '/setup' do
            erb :setup
          end

          get '/chat' do
            has_session?
            erb :chat
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
