# Define : keepalived::exported_real_server
#
# Define an exported real server. (collected by keepalived::virtual_server)
#
# Parameters :
#        $virtual_server_name : the name of the keepalived::virtual_server collecting real servers
#        $port
#        $weight
#        $ip = "$ipaddress",
#        $check_type = 'TCP_CHECK', # MISC_CHECK , TCP_CHECK or HTTP_GET - if not set, the check is a TCP_CHECK on the port
#                $check_connect_timeout = '2',
#                $check_nb_get_retry = '2',
#                $check_delay_before_retry = '2',
#                $check_misc_path = '', #for MISC_CHECK
#                $check_connect_port = '', #for TCP_CHECK and HTTP_GET
#                $check_url_path = '', #for HTTP_GET
#                $check_url_digest = '' #for HTTP_GET
#
define keepalived::exported_real_server (
	$virtual_server_name,
	$port,
	$weight = '100',
	$ip = "$ipaddress",
	$check_type = 'TCP_CHECK', 
		$check_connect_timeout = '2',
		$check_nb_get_retry = '2',
		$check_delay_before_retry = '2',
		$check_misc_path = '', 
		$check_connect_port = '', 
		$check_url_path = '', 
		$check_url_digest = '' 
	) {
	
	if $check_type == 'TCP_CHECK' {
		$real_check_connect_port = $check_connect_port ? {
			'' => $port,
			default => $check_connect_port,
		}
	}

	@@file{"/var/lib/puppet/modules/keepalived/real_servers/${virtual_server_name}-$name":
		ensure => present,
		content => template("keepalived/real_server.erb"),
		before => Exec["concat_/etc/keepalived/keepalived.conf"],
		notify => Exec["reload-keepalived"],
		tag => "keepalived-exported_real_server-$virtual_server_name",
	}

	#Configure DSR on real server (loopback interface and arp config)
	Exec <<| tag == "keepalived-exported-dsr-config-$virtual_server_name" |>>
	
	#Used with @@concat::fragment in keepalived::virtual_server
	#Concat::Fragment <<| tag == "keepalived-exported-dsr-config-$virtual_server_name" |>>
}
