#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "aggregate", "nagios_states")

module MCollective
  class Aggregate
    describe Nagios_states do
      describe "#startup_hook" do
        it "should set the correct result hash" do
          result = Nagios_states.new(:test, [], "%d", :test_action)
          result.result.should == {:value => {"OK" => 0,
                                              "WARNING" => 0,
                                              "CRITICAL" => 0,
                                              "UNKNOWN" => 0},
                                   :type => :collection,
                                   :output => :test}
          result.aggregate_format.should == "%d"
        end

        it "should set a default aggregate format" do
          result = Nagios_states.new(:test, [], nil, :test_action)
          result.aggregate_format.should == "%10s : %s"
        end
      end

      describe "process_result" do
        it "should add the reply value to the results hash" do
          result = Nagios_states.new(:test, [], nil, :test_action)
          result.process_result(0, nil)
          result.process_result(1, nil)
          result.process_result(2, nil)
          result.process_result(3, nil)
          result.result[:value]["OK"].should == 1
          result.result[:value]["WARNING"].should == 1
          result.result[:value]["CRITICAL"].should == 1
          result.result[:value]["UNKNOWN"].should == 1
        end

        it "should add to the 'unkown' field if nrpe result is undefined" do
          result = Nagios_states.new(:test, [], nil, :test_action)
          result.process_result(nil, nil)
          result.result[:value]["UNKNOWN"].should == 1
        end
      end
    end
  end
end
