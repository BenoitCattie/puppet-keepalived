# Class: keepalived::server
#
# This class manage keepalived server installation and configuration. 
#
class keepalived::server {

	package { keepalived: ensure => installed }

	service { keepalived:
		ensure => running,
		enable => true,
		require => Package["keepalived"],
	}

        concatenated_file { "/etc/keepalived/keepalived.conf": 
                dir => "/var/lib/puppet/modules/keepalived/real_servers", 
                header => "/etc/keepalived/PP_keepalived.conf.header", 
                require => Package["keepalived"], 
                before => Exec["reload-keepalived"], 
        }
 
        file {
                "/etc/keepalived/PP_keepalived.conf.header":
                        content => template("keepalived/keepalived.conf.header.erb"),
                        mode => 0644, owner => root, group => 0,
                        before => Concatenated_file["/etc/keepalived/keepalived.conf"],
                       notify => Exec["reload-keepalived"],
        }

	exec{"reload-keepalived":
		command => "/etc/init.d/keepalived reload",
                refreshonly => true,
        }

	file{"/var/lib/puppet/modules/keepalived": ensure => directory}
}
