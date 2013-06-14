Editor = 'vi'

module PDConfig

	$dir = File.dirname(__FILE__)

	class Bash < PDModule
		def self.conf
			edit "~/.bashrc"
		end
		def self.reload
			#exec "source ~/.bashrc"
		end
	end

	class Dpkg < PDModule
		def self.list(s)
			exec "dpkg -l | grep #{s}"
		end
		def self.legend
			puts
			puts '[First letter - expected status]'
			['i - install','r - remove','p - purge','h - hold','u - unkown'].each {|x| puts "\t" + x}

			puts '[Second letter - current status]'
			['n - not installed','i - installed','c - only config-files installed','u - unpacked','f - half-configured','h - half-installed','w - awaiting for other package triggers','t - triggers pending'].each {|x| puts "\t" + x}

			puts '[Third letter - error state]'
			puts "\tr - package broken, reinstallation required"
			puts
		end
	end

	class Nginx < PDModule
		Path='/opt/nginx/'
		def self.conf(vhost=nil)
			if vhost
				edit "#{Path}conf/servers/#{vhost}.conf"
			else
				edit "#{Path}conf/nginx.conf"
			end
		end
		def self.confdir
			cd "#{Path}conf"
		end
		def self.list
			Dir["#{Path}conf/servers/*.conf"].each { |x| puts x.split('/').last[0..-6] }
		end
		def self.start
			exec "#{Path}sbin/nginx"
		end
		def self.reload
			exec "#{Path}sbin/nginx -s reload"
		end
		def self.stop
			exec "#{Path}sbin/nginx -s stop"
		end
	end

	class Postfix < PDModule
		def self.conf
			edit '/etc/postfix/main.cf'
		end
		def self.restart
			exec '/etc/init.d/postfix restart'
		end
		def self.test(to)
			exec 'echo "Testing mail delivery" | mail -s "Test email" ' + to
		end
	end

	class Rails < PDModule
		Path = '/home/virtual/'
		def self.restart(name)
			if Dir.exists?(Path + name)
				exec "touch #{Path}#{name}/tmp/restart.txt"
			else
				syntax_error 3
			end
		end
		def self.db(name)
			edit Path + name + '/config/database.yml'
		end
		def self.logs(name)
			p = Path + name + '/log/'
			logs = Dir[p+'*']
			logs.sort! do |x,y|
				test(?M,x) <=> test(?M,y)
			end
			puts "Showing: #{logs.last}"
			puts
			exec "tail -f #{logs.last}"
		end
	end

	class Mysql < PDModule
		Path='/etc/mysql/'

		def self.db(db)
			exec "mysql -p #{db}"
		end

		def self.conf
			exec "#{Editor} #{Path}my.cnf"
		end

		def self.restart
			exec "/etc/init.d/mysql restart"
		end
		def self.backup
			exec "#{Editor} /etc/default/automysqlbackup"
		end
	end

	class Mongo < PDModule
		def self.start
			exec "/etc/init.d/mongodb start"
		end
		def self.stop
			exec "/etc/init.d/mongodb stop"
		end
		def self.restart
			exec "/etc/init.d/mongodb restart"
		end
		def self.conf
			edit " /etc/mongodb.conf"
		end
	end

	class Apache < PDModule
		def self.conf
			edit "/etc/apache2/apache2.conf"
		end

		def restart
			exec "/etc/init.d/apache2 restart"
		end
	end

	class Mumble < PDModule
		def self.conf
			exec "/etc/mumble-server.ini"
		end
		def restart
			exec "/etc/init.d/mumble-server restart"
		end
	end

	class Php < PDModule
		def self.conf
			exec "#{Editor} /etc/php5/apache2/php.ini"
		end
	end

	class Ftp < PDModule
		Path = '/etc/proftpd/'

		def self.conf(type=nil)
			if type == 'tls'
				edit "#{Path}tls.conf"
			else
				edit "#{Path}proftpd.conf"
			end
		end

		def self.adduser(name)
			exec "#{dir}scripts/ftp/add-user #{name}"
		end

		def self.cert
			exec "#{dir}scripts/ftp/generate-cert"
		end

		def self.restart
			exec "/etc/init.d/proftpd restart"
		end
	end

	class Ssh < PDModule
		Path = '/etc/ssh/'
		def self.conf
			edit(Path + 'sshd_config')
		end
		def self.confdir
			cd(Path)
		end
		def self.keygen
			exec "ssh-keygen -t rsa"
		end
	end

	class Backup < PDModule
		def self.db
			#exec "mysqldump -u root -p  > /root/zapas/dump.sql"
		end
		def self.root
			#tar -chzf /home/ftp/backup/out/`date +%Y-%m-%d`.root.tar.gz /root
		end
	end

	class Vim < PDModule
		def self.install
			exec "cp #{$dir}/defaults/.vimrc ~/"
		end
	end
	
	class Meta < PDModule
		def self.code
			edit "#{dir}pd"
		end
		def self.conf
			edit __FILE__
		end
	end

end
