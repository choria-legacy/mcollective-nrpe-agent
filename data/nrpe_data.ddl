metadata  :name         => "Nrpe",
          :description  => "Checks the exit codes of executed Nrpe commands",
          :author       => "P Loubser",
          :license      => "ASL 2.0",
          :version      => "1.0",
          :url          => "http://marionette-collective.org/",
          :timeout      => 1

dataquery :description => "Runs a Nrpe command and returns the exit code" do
  input   :query,
          :prompt       => "Command",
          :description  => "Valid Nrpe command",
          :type         => :string,
          :validation    => :string,
          :maxlength    => 20

  output  :exitcode,
          :description => "Exit code of Nrpe command",
          :display_as => "Exit Code"
end
