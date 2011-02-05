#
# Generate a fixed random password
# 
#  genpasswd()
#
#
module Puppet::Parser::Functions
        newfunction(:genpasswd, :type => :rvalue) do |args|
		dirname = "/var/lib/puppet/modules/keepalived/functions/"

		#Checking directory and permissions
		if ! File.directory?(dirname)
			raise Puppet::ParseError, "You must create #{dirname} directory on your puppetmaster"
		end
		if ! File.writable?(dirname)
			raise Puppet::ParseError, "#{dirname} directory must be writable by puppetmaster. Change permission."
		end

		#Generate fixed random password
		filename = dirname + "genpasswd_" + args[0]

		if  File.exist?(filename)
			parser.watch_file(filename)
			lines = IO.readlines(filename)
			passwd = lines[lines.length - 1].chomp
		else
			chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a 
			passwd = Array.new(8, '').collect{chars[rand(chars.size)]}.join
			fput = File.open(filename, 'a') {|fd| fd.puts passwd }
		end
		passwd
        end
end
