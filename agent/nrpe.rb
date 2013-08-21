module MCollective
  module Agent
    class Nrpe<RPC::Agent

      action "runallcommands" do
        reply[:commands] = {}
        p = Nrpe.all_command_plugins
        p.each do |name,cmd|
          output = ""
          exitcode, output = Nrpe.run(name)

          reply[:commands][name] = {
            :exitcode=>exitcode,
            :output=> output
          }
        end
      end

      action "runcommand" do
        reply[:exitcode], reply[:output] = Nrpe.run(request[:command])
        reply[:command] = request[:command]

        case reply[:exitcode]
          when 0
            reply.statusmsg = "OK"

          when 1
            reply.fail "WARNING"

          when 2
            reply.fail "CRITICAL"

          else
            reply.fail "UNKNOWN"
        end

        if reply[:output] =~ /^(.+)\|(.+)$/
          reply[:output] = $1
          reply[:perfdata] = $2
        else
          reply[:perfdata] = ""
        end
      end

      # Runs an Nrpe command and returns the command output and exitcode
      # If the command does not exist run will return exitcode 3.
      #
      # The Nrpe configuration directory and file containing checks
      # must be specified in server.cfg
      #
      # Example :
      #          plugin.nrpe.conf_dir = /etc/nagios/nrpe
      #          plugin.nrpe.conf_file = checks.nrpe
      def self.run(command)
        nrpe_command = Nrpe.plugin_for_command(command)

        return 3, "No such command: #{command}" unless nrpe_command

        output = ""
        shell = Shell.new(nrpe_command, {:stdout => output, :chomp => true})
        shell.runcommand
        exitcode = shell.status.exitstatus
        return exitcode, output
      end

      def self.plugin_for_command(command)
        plugin = Nrpe.all_command_plugins[command]
        return { :cmd => plugin } if plugin
        nil
      end

      def self.all_command_plugins
        ret = {}
        files = []
        config = Config.instance
        fdir = config.pluginconf["nrpe.conf_dir"] || "/etc/nagios/nrpe.d"
        if File.directory?(fdir)
          Dir.glob("#{dir}/*.cfg") do | check |

            if check =~ /([^\/]+)\.cfg/
              files << check
            end
          end
        end
        if config.pluginconf["nrpe.conf_file"]
          files << "#{fdir}/#{config.pluginconf['nrpe.conf_file']}"
        end

        files.each do |fname|
          if File.exist?(fname)
            File.readlines(fname).each do |check|
              check.chomp!
              if check =~ /command\[(.+?)\]\s*=\s*(.+)$/
                ret[$1] = $2
              end
            end
          end
        end

        ret
      end

    end
  end
end
