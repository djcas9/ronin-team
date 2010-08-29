require 'rubygems'
require 'sinatra'
require 'faye'
require 'pp'

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