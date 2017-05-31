require 'shellwords'

require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class RunUntilSuccess
    extend Plugin

    register(:command, id: :path_run_until_success, parent: :path, name: 'run_until_success', short_desc: 'run-until-success', desc: 'print out the path of the file for the run-until-success module') { puts __FILE__ }

    register(:command, id: :run_until_success, parent: nil, name: 'run_until_success', short_desc: 'run-until-success CMD ARGS', desc: 'run the command until it succeeds') { |cmd, *args|
      cnt = 0
      full_command = [cmd, *args].map { |v|
        (v =~ /^(\||\d?>|<|\$\(|;|[&]{1,2}$|'.*'$)/).nil? ? Shellwords.escape(v).gsub(/\\*\+/, '+').gsub(/\\*[{]\\*[{]\\*([#])?/, '{{\1').gsub(/\\*[}]\\*[}]/, '}}').gsub(/\\*[*]/, '*') : v
      }
      success = false
      until success
        cnt += 1
        puts "\n#{" Attempt #{cnt} ".center(40, '=')}\n\n"
        system(full_command.join(' '))
        success = $?.success?
      end
    }
  end
end