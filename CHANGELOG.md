# Changelog

Change history for mcollective-nrpe.

## 3.1.0

* Fully qualified call to ::MCollective::Shell to avoid clash with Shell agent
  (MCOP-425)
* Add "runallcommand" action to the agent (PR#5, PR#14)
* Add "args" parameter to the "runcommand" action (PR#15)

## 3.0.3

Released 2014-06-18

* Added pl:packaging to support {yum,apt}.puppetlabs.com (MCOP-74)
