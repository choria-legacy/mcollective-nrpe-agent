module MCollective
  module Data
    class Nrpe_data<Base

      # Only activate Nrpe data plugin if agent plugin has been loaded
      activate_when{ PluginManager["nrpe_agent"]}

      query do |command|
        nrpe_command = Agent::Nrpe.plugin_for_command(command)[:cmd]

        Log.debug("Running Nrpe command '#{command}' : '#{nrpe_command}'")
        result[:exitcode], _ = Agent::Nrpe.run(command)
      end
    end
  end
end
# vi:tabstop=2:expandtab:ai
