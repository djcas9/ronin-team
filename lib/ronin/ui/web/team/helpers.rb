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

require 'rack'
require 'json'

module Ronin
  module UI
    module Web
      module Team
        module Helpers
          include Rack::Utils

          alias h escape_html

          #
          # Renders a JSON blob.
          #
          # @param [Object] obj
          #   The object to convert to a JSON blob.
          #
          # @return [String]
          #   The encoded JSON blob.
          #
          def json(obj)
            content_type :json

            obj = obj.to_s unless obj.respond_to?(:to_json)
            return obj.to_json
          end

          def seen_intro?
            session[:seen_intro] == true
          end

          def no_session?
            session[:username].nil?
          end

          def has_session?
            !(no_session?)
          end

          #
          # The flash messages for the session.
          #
          # @return [Hash]
          #   The flash messages and their categories.
          #
          def flash
            if session[:flash] && session[:flash].class != Hash
              session[:flash] = {}
            else
              session[:flash] ||= {}
            end
          end
        end
      end
    end
  end
end
