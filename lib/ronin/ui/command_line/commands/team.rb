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

require 'ronin/ui/command_line/command'
require 'ronin/ui/web/team/app'

module Ronin
  module UI
    module CommandLine
      module Commands
        #
        # The `ronin team` command.
        #
        class Team < Command
          
          desc 'Starts the Ronin Team web application'
          class_option :host, :type => :string, :aliases => '-I'
          class_option :port, :type => :numeric, :aliases => '-p'

          def execute
            UI::Web::Team::App.run!(options)
          end

        end
      end
    end
  end
end
