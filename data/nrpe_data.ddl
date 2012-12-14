metadata  :name         => "nrpe",
          :description  => "Checks the exit codes of executed Nrpe commands",
          :author       => "P Loubser",
          :license      => "ASL 2.0",
          :version      => "3.0.1",
          :url          => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
          :timeout      => 4

requires :mcollective => "2.2.1"

dataquery :description => "Runs a Nrpe command and returns the exit code" do
  input   :query,
          :prompt       => "Command",
          :description  => "Valid Nrpe command",
          :type         => :string,
          :validation   => '\A[a-zA-Z0-9_-]+\z',
          :maxlength    => 20

  output  :exitcode,
          :description => "Exit code of Nrpe command",
          :display_as  => "Exit Code"
end
