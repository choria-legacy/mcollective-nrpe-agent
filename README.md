#MCollective NRPE Agent

Often after just doing a change on servers you want to just be sure that they’re all going to pass a certain nagios check.

Say you’ve deployed some new code and restarted tomcat, there might be a time while you will experience high loads, you can very quickly determine when all your machines are back to normal using this. It can take nagios many minutes to check all your machines which is a totally unneeded delay in your deployment process.

If you put your nagios checks on your servers using the common Nagios NRPE then this agent can be used to quickly check it across your entire estate.

I wrote a blog post on using this plugin to aggregate checks for Nagios: [Aggregating Nagios Checks With MCollective](http://www.devco.net/archives/2010/07/03/aggregating_nagios_checks_with_mcollective.php)

##Setting up NRPE
This agent makes an assumption or two about how you set up NRPE, in your nrpe.cfg add the following:

```
include_dir=/etc/nagios/nrpe.d/
```

You should now set your commands up one file per check command, for example /etc/nagios/nrpe.d/check_load.cfg:

```
command[check_load]=/usr/lib64/nagios/plugins/check_load -w 1.5,1.5,1.5 -c 2,2,2
```

With this setup the agent will now be able to find your check_load command.
I’ve added a Puppet define and template to help you create checks like this [on GitHub](http://github.com/puppetlabs/mcollective-plugins/tree/master/agent/nrpe/puppet/)

##Agent Installation
Follow the basic [plugin install guide](http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/InstalingPlugins)

##Agent Configuration
You can set the directory where the NRPE cfg files live using plugin.nrpe.conf_dir

##Usage
###Using generic mco rpc
You can use the normal mco rpc script to run the agent:

```
mco rpc nrpe runcommand command=check_load
Determining the amount of hosts matching filter for 2 seconds .... 43

 * [ ============================================================> ] 43 / 43

 Finished processing 43 hosts in 415.22 ms
```

###Supplied Client
Or we provide a client specifically for this agent that is a bit more appropriate for the purpose:
The client supports:

```
% mco nrpe -W /dev_server/ check_load

 * [ ============================================================> ] 3 / 3


Finished processing 3 hosts in 329.93 ms

              OK: 3
         WARNING: 0
        CRITICAL: 0
         UNKNOWN: 0
```

By default it only shows the problems:
```
% mco nrpe check_disks

 * [ ============================================================> ] 43 / 43

your.box.net                      status=CRITICAL

Finished processing 43 hosts in 439.98 ms

              OK: 42
         WARNING: 0
        CRITICAL: 1
         UNKNOWN: 0
```

To see all the statusses:

```
% mco nrpe -W /dev_server/ check_load -v
Determining the amount of hosts matching filter for 2 seconds .... 3

 * [ ============================================================> ] 3 / 3

dev1.your.net                      status=OK
    OK - load average: 0.00, 0.00, 0.00

dev2.your.net                      status=OK
    OK - load average: 0.00, 0.00, 0.00

dev3.your.net                      status=OK
    OK - load average: 0.00, 0.00, 0.00


---- check_load NRPE results ----
           Nodes: 3
     Pass / Fail: 3 / 0
      Start Time: Tue Dec 29 22:24:10 +0000 2009
  Discovery Time: 2006.46ms
      Agent Time: 334.85ms
      Total Time: 2341.31ms

Nagios Statusses:
              OK: 3
         WARNING: 0
        CRITICAL: 0
         UNKNOWN: 0
```

###Data Plugin

The NRPE Agent ships with a data plugin that will enable you to filter discovery on the results of NRPE commands.

```
mco rpc rpcutil ping -S "Nrpe('check_disk1').exitcode=0"
Determining the amount of hosts matching filter for 2 seconds .... 43

 * [ ============================================================> ] 43 / 43

 Finished processing 43 hosts in 415.22 ms

```
