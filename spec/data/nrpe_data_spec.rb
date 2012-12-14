#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "data", "nrpe_data")
require File.join(File.dirname(__FILE__), "../../", "agent", "nrpe")

module MCollective
  module Data
    describe "#query_data" do
      before do
        @ddl = mock
        @ddl.stubs(:meta).returns({:timeout => 1})
        DDL.stubs(:new).returns(@ddl)
      end

      it "should return the correct exit code" do
        MCollective::Agent::Nrpe.expects(:plugin_for_command).returns({:cmd => "test_command"})
        MCollective::Agent::Nrpe.expects(:run).returns(0, "")
        plugin = Nrpe_data.new
        plugin.query_data("test_command")
        plugin.result.exitcode.should == 0
      end

      it "should return unknown if the command cannot be found" do
        MCollective::Agent::Nrpe.expects(:plugin_for_command).returns(nil)
        plugin = Nrpe_data.new
        plugin.query_data("test_command")
        plugin.result.exitcode.should == 3
      end
    end
  end
end
