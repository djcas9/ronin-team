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

require 'sinatra'
require 'faye'
require 'pp'

module Ronin
  module UI
    module Web
      class Team < Sinatra::Base

        set :run, true
        set :views, 'views'
        set :public, 'public'

        enable :sessions
        use Faye::RackAdapter, :mount => '/share', :timeout => 45

        before  do
        end

        helpers do

          def has_session?
            return true if session[:username]
            redirect '/setup'
          end

          def no_session!
            return true unless session[:username]
            false
          end

        end

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

        # @env=
        #   {"rack.session"=>{:username=>"Dustin"},
        #    "HTTP_CACHE_CONTROL"=>"max-age=0",
        #    "HTTP_ACCEPT"=>
        #     "application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5",
        #    "HTTP_HOST"=>"10.0.1.6:8080",
        #    "SERVER_NAME"=>"10.0.1.6",
        #    "rack.request.cookie_hash"=>
        #     {"rack.session"=>"BAh7BjoNdXNlcm5hbWUiC0R1c3Rpbg==\n"},
        #    "rack.url_scheme"=>"http",
        #    "HTTP_USER_AGENT"=>
        #     "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-us) AppleWebKit/533.17.8 (KHTML, like Gecko) Version/5.0.1 Safari/533.17.8",
        #    "REQUEST_PATH"=>"/request",
        #    "SERVER_PROTOCOL"=>"HTTP/1.1",
        #    "HTTP_ACCEPT_LANGUAGE"=>"en-us",
        #    "rack.errors"=>#<IO:0x100163b80>,
        #    "async.callback"=>#<Method: Thin::Connection#post_process>,
        #    "REMOTE_ADDR"=>"10.0.1.6",
        #    "PATH_INFO"=>"/request",
        #    "rack.run_once"=>false,
        #    "rack.version"=>[1, 0],
        #    "SERVER_SOFTWARE"=>"thin 1.2.7 codename No Hup",
        #    "rack.request.cookie_string"=>
        #     "rack.session=BAh7BjoNdXNlcm5hbWUiC0R1c3Rpbg%3D%3D%0A",
        #    "SCRIPT_NAME"=>"",
        #    "HTTP_COOKIE"=>"rack.session=BAh7BjoNdXNlcm5hbWUiC0R1c3Rpbg%3D%3D%0A",
        #    "HTTP_VERSION"=>"HTTP/1.1",
        #    "rack.multithread"=>false,
        #    "REQUEST_URI"=>"/request",
        #    "rack.multiprocess"=>false,
        #    "rack.request.query_hash"=>{},
        #    "faye.client"=>
        #     #<Faye::Client:0x1034d8c40
        #      @advice={"reconnect"=>"retry", "timeout"=>60000.0, "interval"=>0.0},
        #      @channels=#<Faye::Channel::Tree:0x1034d8a60 @children={}, @value=nil>,
        #      @endpoint=
      end
    end
  end
end
