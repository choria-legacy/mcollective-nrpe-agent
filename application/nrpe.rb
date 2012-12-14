class MCollective::Application::Nrpe<MCollective::Application
  description "Client to the Nagios Remote Plugin Execution system"
  usage "Usage: nrpe <check_name>"

  def post_option_parser(configuration)
    configuration[:command] = ARGV.shift if ARGV.size > 0
  end

  def validate_configuration(configuration)
    raise "Please specify a check name" unless configuration.include?(:command)
  end

  def main
    nrpe = rpcclient("nrpe")

    nrpe_results = nrpe.runcommand(:command => configuration[:command])

    nrpe_results.each do |result|
      if result[:statuscode] == 0
        exitcode = Integer(result[:data][:exitcode]) rescue 3
      else
        exitcode = 1
      end

      if nrpe.verbose
        printf("%-40s status=%s\n", result[:sender], result[:statusmsg])
        printf("    %-40s\n\n", result[:data][:output])
      else
        if [1,2,3].include?(exitcode)
          printf("%-40s status=%s\n", result[:sender], result[:statusmsg])
          printf("    %-40s\n\n", result[:data][:output]) if result[:data][:output]
        end
      end
    end

    printrpcstats :summarize => true, :caption => "%s NRPE results" % configuration[:command]
  end
end
