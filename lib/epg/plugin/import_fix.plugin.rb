require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class ImportFix
    extend Plugin

    register(:command, id: :path_import_fix, parent: :path, name: 'import_fix', short_desc: 'import-fix', desc: 'print out the path of the file for the import fix module') { puts __FILE__ }

    register(:command, id: :import_fix, parent: nil, name: 'import_fix', short_desc: 'import-fix [folder = "."]', desc: 'find the cases where newlines are missing between import statements in the given folder (or the current folder if no folder given) and any sub-folders') { |folder = '.'|
      folder = File.expand_path(folder)
      Dir.chdir(folder)
      Dir.glob(File.join('**', '*.java')) { |fn|
        fname = File.expand_path(fn, folder)
        lines = IO.readlines(fname)
        lines.each_with_index { |l, i|
          puts "Double import: #{fn}:#{i+1}" if l.chomp =~ /import.*;\s*import/
        }
      }
    }
  end
end