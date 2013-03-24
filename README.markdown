Puppet Glassfish Domain type
============================

This plugin for Puppet adds resource types and providers for managing Glassfish
domains, system-properties, jdbc-connection-pools, jdbc-resources, auth-realms
and application deployment by using the asadmin command line tool.

Copyright - Lars Tobias Skjong-Børsting <larstobi@conduct.no>
Modified - Gavin Williams <fatmcgav@gmail.com>

License: GPLv3

Installation:
=============
This plugin uses the executable "asadmin". For this plugin to work, the
folder where the executable is located must exist in the PATH environment
variable.

Place the "lib" folder and it's subfolders in the module path,
i.e. /etc/puppet/modules/glassfish/lib/...

Example:
========

    include glassfish