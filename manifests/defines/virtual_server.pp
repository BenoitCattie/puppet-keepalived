# Define : keepalived::virtual_server
#
# Define a virtual server. 
#
# Parameters :
#        state : MASTER or BACKUP
#        virtual_router_id
#        virtual_ipaddress
#        virtual_server_port
#        lb_kind = 'DR' : Support only DR in this version
#	 lb_algo = 'wlc
#        interface = 'eth0'
#        priority = '' : If not set, BACKUP will take 100 and MASTER 200

define keepalived::virtual_server ( 
	$state, 
	$virtual_router_id, 
	$virtual_ipaddress,
	$virtual_server_port,
	$lb_kind = 'DR',
	$lb_algo = 'wlc',
	$interface = 'eth0',
	$priority = '' ) {

	#Variables manipulations
	$real_priority = $priority ? {
		'' => $state ? {
			'MASTER' => '200',
			'BACKUP' => '100',
		      },
		default => $priority,
	}

	#Generate a fixed-random password for this virtual server
	$auth_pass = genpasswd("KA-VS-$name")

	#Collect all exported real servers for this virtual server
	File <<| tag == "keepalived-exported_real_server-$name" |>>

	#Construct /etc/keepalived/keepalived.conf
        file {
                "/var/lib/puppet/modules/keepalived/real_servers/$name":
                        content => template("keepalived/virtual_server.erb"),
                        mode => 0644, owner => root, group => 0,
			before => Exec["concat_/etc/keepalived/keepalived.conf"],
			notify => Exec["reload-keepalived"],
        }

        file {
                "/var/lib/puppet/modules/keepalived/real_servers/${name}z":
                        content => "}\n",
			before => Exec["concat_/etc/keepalived/keepalived.conf"],
        }

	# Configure DSR on real servers with exported ressources
	# Be carefull when server reboots

	if $state == "MASTER" { #Export only when MASTER
		@@exec{"add-loopback-DSR-$virtual_ipaddress":
			command => "/sbin/ip addr add ${virtual_ipaddress}/32 dev lo",
			onlyif => "/usr/bin/test -z \"`/sbin/ip addr ls lo | grep ${virtual_ipaddress}/32`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}
		@@exec{"add-arp_announce-config-DSR-$name":
			command => "/sbin/sysctl net.ipv4.conf.all.arp_announce=2",
			onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_announce | grep 2`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}
		@@exec{"add-arp_ignore-config-DSR-$name":
			command => "/sbin/sysctl net.ipv4.conf.all.arp_ignore=1",
			onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_ignore | grep 1`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}

		# In my case i use concat::fragment to construct /etc/network/interfaces
		# This ensure loopback interface will be configure at boot time

		#@@concat::fragment{"network_interfaces_eth0-DSR-$name":
		#	target  => "/etc/network/interfaces",
		#	ensure  => present,
		#	content => "\t#DSR IP for $name\n\tup ip addr add ${virtual_ipaddress}/32 dev lo\n",
		#	order   => 'eth0_20',
		#	tag     => "keepalived-exported-dsr-config-$name",
		#}
	}
 
}
