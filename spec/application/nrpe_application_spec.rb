#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'application', 'nrpe.rb')

module MCollective
  class Application
    describe Nrpe do
      before do
        application_file = File.join(File.dirname(__FILE__), '../../', 'application', 'nrpe.rb')
        @app = MCollective::Test::ApplicationTest.new('nrpe', :application_file => application_file).plugin
      end

      describe '#application_description' do
        it 'should have a descrption set' do
          @app.should have_a_description
        end
      end

      describe '#validate_configuration' do
        it 'should fail if a check name has not been specified' do
          expect{
            @app.validate_configuration
          }.to raise_error
        end
      end

      describe '#main' do
        let(:resultset) do
          [{:data => {:exitcode => 0}, :statuscode => 0, :sender => 'rspec1', :statusmsg => 'ok'},
          {:data => {:exitcode => 1}, :statuscode => 0, :sender => 'rspec2', :statusmsg => 'ok'},
          {:data => {:exitcode => 2}, :statuscode => 0, :sender => 'rspec3', :statusmsg => 'ok'},
          {:data => {:exitcode => 3}, :statuscode => 0, :sender => 'rspec4', :statusmsg => 'ok'},
          {:data => {:exitcode => 1}, :statuscode => 0, :sender => 'rspec5', :statusmsg => 'ok'}]
        end

        let(:rpcclient) { mock }

        before do
          @app.expects(:rpcclient).returns(rpcclient)
          @app.configuration[:command] = "rspec"
          rpcclient.stubs(:stats).returns({:noresponsefrom => ['rspec']})
          @app.expects(:printrpcstats).with(:summarize => true, :caption => "rspec NRPE results")
        end

        it 'should run the command and output the results if verbose is set' do
          rpcclient.expects(:runcommand).returns(resultset)
          rpcclient.stubs(:verbose).returns(true)
          @app.expects(:printf).with("%-40s status=%s\n", 'rspec1', 'ok')
         @app.main
        end

        it 'should run the command and output the results if verbose is not set' do
          rpcclient.expects(:runcommand).returns(resultset)
          rpcclient.stubs(:verbose).returns(false)
          @app.main
        end
      end
    end
  end
end
