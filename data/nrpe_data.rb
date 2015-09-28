module MCollective
  module Data
    class Nrpe_data<Base

      # Only activate Nrpe data plugin if agent plugin has been loaded
      activate_when{ PluginManager["nrpe_agent"] }

      query do |command|
        nrpe_command = Agent::Nrpe.plugin_for_command(command, [])

        if nrpe_command
          Log.debug("Running Nrpe command '#{command}' : '#{nrpe_command}'")
          result[:exitcode], _ = Agent::Nrpe.run(command)
        else
          Log.warn("No Nrpe command '#{command}' found. Returning status UNKNOWN")
          result[:exitcode] = 3
        end
      end
    end
  end
end
