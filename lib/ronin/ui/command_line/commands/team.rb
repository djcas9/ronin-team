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
require 'ronin/database'
require 'ronin/team'

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

          class_option :users, :type => :boolean, :aliases => '-u'
          class_option :add, :type => :hash, :aliases => '-a'
          class_option :remove, :type => :string, :aliases =>' -r'
          class_option :passwords, :type => :hash

          def execute
            if options[:users]
              users!
            elsif options[:add]
              add!
            elsif options[:remove]
              remove!
            elsif options[:passwords]
              passwords!
            else
              UI::Web::Team::App.run!(options)
            end
          end

          protected

          def users!
            Database.setup

            indent do
              Ronin::Team::User.all.each { |user| puts user.name }
            end
          end

          def add!
            Database.setup

            options[:add].each_key do |name|
              unless Ronin::Team::User.count(:name => name) == 0
                print_error "User name #{name.dump} already taken."
                exit -1
              end
            end

            options[:add].each do |name,password|
              print_info "Creating user #{name.dump} ..."

              user = Ronin::Team::User.create(
                :name => name,
                :password => password
              )
            end

            print_info "Users created."
          end

          def remove!
            name = options[:remove]

            Database.setup

            unless (user = Team::User.first(:name => name))
              print_error "Unknown user #{name.dump}"
              exit -1
            end

            user.destroy!

            print_info "Removed user #{name.dump}."
          end

          def passwords!
            Database.setup

            options[:passwords].each do |name,password|
              unless (user = Ronin::Team::User.first(:name => name))
                print_error "Unknown user #{name.dump}."
                exit -1
              end

              print_info "Setting password for user #{name.dump} ..."

              user.password = password
              user.save!
            end

            print_info "User passwords set."
          end

        end
      end
    end
  end
end
