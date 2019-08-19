require 'socket'

require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class SudoSinatra
    extend Plugin

    register(:command, id: :path_sudo_sinatra, parent: :path, name: 'sudo_sinatra', short_desc: 'sudo-sinatra', desc: 'print out the path of the file for the sudo-sinatra module') { puts __FILE__ }

    register(:command, id: :sudo_sinatra, parent: nil, name: 'sudo_sinatra', short_desc: 'sudo-sinatra FILE [HOSTS_NAME]', desc: 'run the specified file with sudo privileges and optionally register a /etc/hosts entry mapping to 127.0.0.1') { |file, hosts_name = nil|
      file = "./#{file}" unless file.start_with?('./')
      if hosts_name.nil?
        system("rbe s -r #{file}")
      else
        if `whoami`.chomp == 'root'
          if Socket.gethostbyname(hosts_name)[3].bytes.join('.') != '127.0.0.1'
            File.open('/etc/hosts', 'a+') { |file| file.print "127.0.0.1\t#{hosts_name}" }
          end
          system("epg sudo-sinatra #{file}")
        else
          system("rbe s -r epg sudo-sinatra #{file} #{hosts_name}")
        end
      end
    }
  end
end