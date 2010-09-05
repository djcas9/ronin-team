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

require 'ronin/team/user'

require 'warden'

Warden::Manager.serialize_into_session { |user| user.id }
Warden::Manager.serialize_from_session { |id| Ronin::Team::User.get(id) }

Warden::Manager.before_failure do |env,opts|
  # Sinatra can be picky about the method used to authenticate
  # so to be sure everything works, let's specify it here.
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do
  def valid?
    params['name'] || params['password']
  end

  def authenticate!

    user = Ronin::Team::User.authenticate(
      :name => params['name'],
      :password => params['password']
    )

    if user
      session[:username] = user.name
      session[:uuid] = UUIDTools::UUID.random_create.to_s
      session[:ipaddr] = env['REMOTE_ADDR']
      session[:agent] = env['HTTP_USER_AGENT']
      session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
      success!(user)
    else
      errors.add(:login, "Username or Password incorrect")
      fail!
    end
  end
end
