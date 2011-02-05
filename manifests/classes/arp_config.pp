# Class: keepalived::arp_config
#
# This class manage arp_config on the real servers
#
class keepalived::arp_config {

	file { "/etc/sysctl.d/60-arp_dsr.conf":
                owner   => root,
                group   => root,
                mode    => 644,
		source => "puppet:///modules/keepalived/arp_dsr.conf",
        }
}
