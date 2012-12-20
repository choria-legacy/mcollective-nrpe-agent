#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "agent", "nrpe.rb")

describe "nrpe agent" do
  before do
    agent_file = File.join([File.dirname(__FILE__), "../../agent/nrpe.rb"])
    @agent = MCollective::Test::LocalAgentTest.new("nrpe", :agent_file => agent_file).plugin
  end

  describe "#runcommand" do
    it "should reply with statusmessage 'OK' of exitcode is 0" do
      MCollective::Agent::Nrpe.expects(:run).with("foo").returns(0)
      result = @agent.call(:runcommand, :command => "foo")
      result.should be_successful
      result.should have_data_items(:exitcode=>0, :perfdata=>"")
      result[:statusmsg].should == "OK"
    end

    it "should reply with statusmessage 'WARNING' of exitcode is 1" do
      MCollective::Agent::Nrpe.expects(:run).with("foo").returns(1)
      result = @agent.call(:runcommand, :command => "foo")
      result.should be_aborted_error
      result.should have_data_items(:exitcode=>1, :perfdata=>"")
      result[:statusmsg].should == "WARNING"
    end

    it "should reply with statusmessage 'CRITICAL' of exitcode is 2" do
      MCollective::Agent::Nrpe.expects(:run).with("foo").returns(2)
      result = @agent.call(:runcommand, :command => "foo")
      result.should be_aborted_error
      result.should have_data_items(:exitcode=>2, :perfdata=>"")
      result[:statusmsg].should == "CRITICAL"
    end

    it "should reply with statusmessage UNKNOWN if exitcode is something else" do
      MCollective::Agent::Nrpe.expects(:run).with("foo")
      result = @agent.call(:runcommand, :command => "foo")
      result.should be_aborted_error
      result.should have_data_items(:exitcode=>nil, :perfdata=>"")
      result[:statusmsg].should == "UNKNOWN"
    end
  end

  describe "#plugin_for_command" do
    let(:config){mock}
    let(:pluginconf){{"nrpe.conf_dir" => "/foo", "nrpe.conf_file" => "bar.cfg"}}

    before :each do
      config.stubs(:pluginconf).returns(pluginconf)
      MCollective::Config.stubs(:instance).returns(config)
    end

    it "should return the command from nrpe.conf_dir if it is set" do
      File.expects(:exist?).with("/foo/bar.cfg").returns(true)
      File.expects(:readlines).with("/foo/bar.cfg").returns(["command[command]=run"])
      MCollective::Agent::Nrpe.plugin_for_command("command").should == {:cmd => "run"}
    end

    it "should return the command from /etc/nagios/nrpe.d if nrpe.conf_dir is unset" do
      pluginconf["nrpe.conf_dir"] = nil
      File.expects(:exist?).with("/etc/nagios/nrpe.d/bar.cfg").returns(true)
      File.expects(:readlines).with("/etc/nagios/nrpe.d/bar.cfg").returns(["command[command]=run"])
      MCollective::Agent::Nrpe.plugin_for_command("command").should == {:cmd => "run"}
    end
  end

  describe "#run" do
    it "should run the command found in #plugin_for_command and return output and exitcode" do
      shell = mock
      status = mock

      MCollective::Agent::Nrpe.expects(:plugin_for_command).with("foo").returns({:cmd => "foo"})
      MCollective::Shell.stubs(:new).returns(shell)
      shell.expects(:runcommand)
      shell.expects(:status).returns(status)
      status.expects(:exitstatus).returns(0)

      MCollective::Agent::Nrpe.run("foo").should == [0, ""]
    end

    it "should return 3 and an error if the command could not be found in #plugin_for_command" do
      MCollective::Agent::Nrpe.expects(:plugin_for_command).with("foo").returns(nil)
      MCollective::Agent::Nrpe.run("foo").should == [3, "No such command: foo"]
    end
  end
end
