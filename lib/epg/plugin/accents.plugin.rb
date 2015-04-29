require 'everyday_natsort'

require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class Accents
    extend Plugin

    register(:command, id: :path_accents, parent: :path, name: 'accents', short_desc: 'accents', desc: 'print out the path of the file for the strip accents module') { puts __FILE__ }

    register(:command, id: :accents, parent: nil, name: 'accents', short_desc: 'accents', desc: 'take the input from stdin and send the sanatized version to stdout') {
      val = nil
      str = ''
      begin
        val = $stdin.gets
        str << val unless val.nil?
      end until val.nil? || $stdin.eof?
      puts EverydayNatsort.strip_accents(str)
    }
  end
end