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

require 'ronin/model'

require 'dm-types'

module Ronin
  module Team
    class User

      include Model

      # The primary key of the user
      property :id, Serial

      # The user name
      property :user_name, String, :required => true

      # The encrypted password of the user
      property :encrypted_password, BCryptHash, :required => true

      # The clear-text password
      attr_reader :password

      # The confirmation password
      attr_accessor :password_confirmation

      validates_confirmation_of :password

      #
      # Sets the password of the user.
      #
      # @param [String] new_password
      #   The new password for the user.
      #
      # @return [String]
      #   The new password of the user.
      #
      def password=(new_password)
        self.encrypted_password = new_password
        @password = new_password
      end

    end
  end
end
