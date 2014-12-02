module MCollective
  module Agent
    class Nrpe<RPC::Agent

      action "runcommand" do
        reply[:exitcode], reply[:output] = Nrpe.run(request[:command], request[:args])
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
      def self.run(command, args)
        nrpe_command = Nrpe.plugin_for_command(command,args)
        return 3, "No such command: #{command}" unless nrpe_command

        output = ""
        shell = Shell.new(nrpe_command[:cmd], {:stdout => output, :chomp => true})
        shell.runcommand
        exitcode = shell.status.exitstatus

        return exitcode, output
      end

      def self.plugin_for_command(command,args)
        fnames = []
        config = Config.instance

        fdir = config.pluginconf["nrpe.conf_dir"] || "/etc/nagios/nrpe.d"

        if config.pluginconf["nrpe.conf_file"]
          fnames << "#{fdir}/#{config.pluginconf['nrpe.conf_file']}"
        else
          fnames |= Dir.glob("#{fdir}/*.cfg")
        end

        fnames.each do |fname|
          if File.exist?(fname)
            File.readlines(fname).each do |check|
              check.chomp!

              if check =~ /command\[#{command}\]\s*=\s*(.+)$/
                return {:cmd => self.get_command_with_args($1,args)}
              end
            end
          end
        end
        nil
      end

      def self.get_command_with_args(command, args)
        arguments = []
        return command unless args
        args.split('!').to_enum.with_index.each do |arg, i|
          arguments.push(["$ARG#{i+1}$","#{arg}"])
        end
        arguments.each {|arg| command.gsub!(arg[0], arg[1])}
        return command
      end
    end
  end
end
