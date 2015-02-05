require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class ImportFix
    extend Plugin

    register :option, sym: :import_fix, names: %w(-i --import-fix), desc: 'print out files with messed up imports'

    register(:before_run, order: 0) { |options|
      if options[:import_fix]
        Dir.glob(File.join('**', '*.java')) { |fn|
          fname = File.expand_path(fn)
          lines = IO.readlines(fname)
          lines.each_with_index { |l, i|
            puts "Double import: #{fn}:#{i+1}" if l.chomp =~ /import.*;\s*import/
          }
        }
      end
    }
  end
end