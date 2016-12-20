require 'fileutils'
require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class Archive
    extend Plugin

    register(:command, id: :path_archive, parent: :path, name: 'archive', short_desc: 'archive', desc: 'print out the path of the file for the download archive module') { puts __FILE__ }

    register(:command, id: :archive, parent: nil, name: 'archive', short_desc: 'archive folder files...', desc: 'sort the provided files into sub-folders of the provided folder') { |folder, *files|
      folder = File.expand_path(folder)
      Dir.mkdir(folder) unless Dir.exist?(folder)
      files.each { |fname|
        file = File.expand_path(fname)
        if File.exist?(file)
          first_char = fname[0].downcase
          dir_name = first_char =~ /[a-z]/ ? first_char : '#'
          dir_name = File.expand_path(dir_name, folder)
          Dir.mkdir(dir_name) unless Dir.exist?(dir_name)
          FileUtils.mv file, File.expand_path(fname, dir_name), verbose: !options[:silent], noop: options[:noop]
        end
      }
    }

    register :flag, name: :noop, parent: :archive, aliases: %w(-n), type: :boolean, desc: 'don\'t actually do the move'
    register :flag, name: :silent, parent: :archive, aliases: %w(-s), type: :boolean, desc: 'disable verbose mode'
  end
end