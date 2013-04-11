Puppet Glassfish plugin
=======================

This plugin for Puppet installs Glassfish Application Server and adds resource 
types and providers for managing Glassfish domains, system-properties, 
jdbc-connection-pools, jdbc-resources, custom-resources, auth-realms and 
application deployment by using the asadmin command line tool.

 * Copyright - Lars Tobias Skjong-Børsting <larstobi@conduct.no>
 * Modified - Gavin Williams <fatmcgav@gmail.com>
 * Modified - Krzysztof Suszyński <krzysztof.suszynski@wavesoftware.pl>

License: GPLv3

Installation:
=============
This plugin uses the executable `asadmin` of Glassfish instalation. Plugin 
installs Glassfish in version 3.1.2.2 using `java-7-oracle` (also supports 
other JDK versions: `java-7-oracle`, `java-7-openjdk`, `java-6-oracle`, 
`java-6-openjdk`). It will also starts it as a service.


Example simple usage:
=====================

    include glassfish
    
or

    class { glassfish:
      java => 'java-6-openjdk'
    }
   
More examples on using various types:
=====================================


    Domain {
      user         => 'gfish',
      asadminuser  => 'admin',
      passwordfile => '/home/gfish/.aspass',
    }
    
    domain {
      'mydomain':
        ensure => present;
    
      'devdomain':
        ensure   => present,
        portbase => '5000';
    
      'myolddomain':
        ensure => absent;
    }
    
    Systemproperty {
      user         => 'gfish',
      asadminuser  => 'admin',
      passwordfile => '/home/gfish/.aspass',
    }
    
    systemproperty { 'search-url':
      ensure   => present,
      portbase => '5000',
      value    => 'http://www.google.com',
      require  => Domain['devdomain'];
    }
    
    Jdbcconnectionpool {
      ensure              => present,
      user                => 'gfish',
      asadminuser         => 'admin',
      passwordfile        => '/home/gfish/.aspass',
      datasourceclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
      resourcetype        => 'javax.sql.ConnectionPoolDataSource',
      require             => Glassfish['mydomain'],
    }
    
    jdbcconnectionpool {'MyPool':
      properties => {
        'password' => 'mYPasS',
        'user' => 'myuser',
        'url' => 'jdbc:mysql://host.ex.com:3306/mydatabase',
        'useUnicode' => true,
        'characterEncoding' => 'utf8',
        'characterResultSets' => 'utf',
        'autoReconnect' => true,
        'autoReconnectForPools' => true,
      }
    }
    
    Jdbcresource {
      ensure       => present,
      user         => 'gfish',
      passwordfile => '/home/gfish/.aspass',
    }
    
    jdbcresource { 'jdbc/MyPool':
      connectionpool => 'MyPool',
    }
    
    Customresource {
      ensure       => present,
      restype => 'java.util.Properties',
      factoryclass => 'org.glassfish.resources.custom.factory.PropertiesFactory',
    }
    
    customresource { 'custom/SampleProperties':
      properties => {
        "type" => 'local',
        "path" => '/tmp/published',
      }
    }
    
    Application {
      ensure       => present,
      user         => 'gfish',
      passwordfile => '/home/gfish/.aspass',
    }
    
    application {
      'pluto':
        source => '/home/gfish/pluto.war';
    
      'myhello':
        source  => '/home/gfish/hello.war',
        require => Application['pluto'];
    }
    
    Jvmoption {
      ensure       => present,
      user         => 'gfish',
      passwordfile => '/home/gfish/.aspass',
    }
    
    jvmoption {
      ['-DjvmRoute=01', '-server']:
    }
    
    Authrealm {
      ensure       => present,
      user         => 'gfish',
      asadminuser  => 'admin',
      passwordfile => '/Users/larstobi/.aspass',
    }
    
    authrealm {
      'agentRealm':
        ensure     => present,
        classname  => 'com.sun.identity.agents.appserver.v81.AmASRealm',
        properties => ['jaas-context=agentRealm:foo=bar'],
        require    => Domain['mydomain'];
    }

