require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class STPrompt
    extend Plugin

    register(:command, id: :path_stprompt, parent: :path, name: 'stprompt', short_desc: 'stprompt', desc: 'print out the path of the file for the script tester prompt extraction module') { puts __FILE__ }

    register(:command, id: :stprompt, parent: nil, name: 'stprompt', short_desc: 'stprompt', desc: 'take the input from stdin and send the extracted prompting to stdout') {
      val = nil
      str = ''
      begin
        val = $stdin.gets
        str << val unless val.nil?
      end until val.nil? || $stdin.eof?
      str2 = []
      str.each_line { |l|
        l = l.chomp.strip
        if l =~ /^\s*Prompt\s*".+?":\s*"(.+?)"\s*$/
          str2 << $1
        end
      }
      puts str2.join(' ')
    }
  end
end