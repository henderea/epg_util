require 'readline'
require 'json'
require 'everyday_natsort_kernel'
require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class JsonValue
    extend Plugin

    register(:command, id: :path_json_value, parent: :path, name: 'json_value', short_desc: 'json-value', desc: 'print out the path of the file for the json value extractor module') { puts __FILE__ }

    register :command, id: :json_value, parent: nil, name: 'json_value', short_desc: 'json-value SUBCOMMAND ARGS...', desc: 'extract values from a json file'

    register(:command, id: :json_value_get, parent: :json_value, name: 'get', short_desc: 'get filename path', desc: 'extract a value from a json file', long_desc: <<EOS) { |filename, path|
Extract a value from a JSON file.  Use the format a->b->c to get root[a][b][c]
EOS
      full_filename = File.expand_path(filename)
      unless File.exist?(full_filename)
        puts "Could not find #{filename}"
        exit 1
      end
      data = JSON.parse(IO.read(full_filename))
      path_pieces = path.split(/->/)
      cur_data = itr(path_pieces, data)
      if cur_data.is_a?(Array) || cur_data.is_a?(Hash)
        puts JSON.pretty_generate(cur_data)
      else
        puts cur_data.inspect
      end
    }

    register(:command, id: :json_value_load, parent: :json_value, name: 'load', short_desc: 'load filename', desc: 'load a json file and run queries on it', long_desc: <<EOS) { |filename|
Load a JSON file and run queries on it.  Once the JSON is loaded, the user will be presented with a prompt for JSON path with tab completion.  Use the format a->b->c to get root[a][b][c]
EOS
      full_filename = File.expand_path(filename)
      unless File.exist?(full_filename)
        puts "Could not find #{filename}"
        exit 1
      end
      data = JSON.parse(IO.read(full_filename))
      Readline.completion_append_character = nil
      Readline.completer_word_break_characters = '> '
      Readline.completion_proc = ->(_) { get_suggestions(Readline.line_buffer.gsub(/^\\d\s*/, '').split(/->/, -1), data) }
      loop {
        path = Readline.readline('>> ', true)
        exit 0 if path == '\q'
        if path == '\h'
          puts <<-'EOS'
<path>    get the value at <path>, where the path separator is '->'
\q        exit
\h        print this help
\d <path> print the elements in <path>
EOS
        elsif path =~ /\\d\s*(.*)/
          list = get_suggestions($1.split(/->/, -1), data, true)
          puts list.join(', ') if list
        else
          path_pieces = path.split(/->/)
          cur_data = itr(path_pieces, data)
          if cur_data.is_a?(Array) || cur_data.is_a?(Hash)
            puts JSON.pretty_generate(cur_data)
          else
            puts cur_data.inspect
          end
        end
      }
    }

    register(:command, id: :json_value_load_multi, parent: :json_value, name: 'load_multi', short_desc: 'load-multi filename', desc: 'load multiple json files and run queries on them', long_desc: <<EOS) { |*filenames|
Load multiple JSON files and run queries on them.  Once the JSON is loaded, the user will be presented with a prompt for JSON path with tab completion.  Use the format i->a->b->c to get root[a][b][c] of file at index i
EOS
      missing_files = filenames.reject { |filename| File.exist?(File.expand_path(filename)) }
      unless missing_files.nil? || missing_files.empty?
        puts "Could not find #{missing_files.join(', ')}"
        exit 1
      end
      full_filenames = filenames.map { |filename| File.expand_path(filename) }
      data = []
      full_filenames.each { |full_filename| data << JSON.parse(IO.read(full_filename)) }
      Readline.completion_append_character = nil
      Readline.completer_word_break_characters = '> '
      Readline.completion_proc = ->(_) { get_suggestions(Readline.line_buffer.gsub(/^\\d\s*/, '').split(/->/, -1), data) }
      loop {
        path = Readline.readline('>> ', true)
        exit 0 if path == '\q'
        if path == '\h'
          puts <<-'EOS'
<path>    get the value at <path>, where the path separator is '->'
\q        exit
\h        print this help
\d <path> print the elements in <path>
EOS
        elsif path =~ /\\d\s*(.*)/
          list = get_suggestions($1.split(/->/, -1), data, true)
          puts list.join(', ') if list
        else
          path_pieces = path.split(/->/)
          cur_data = itr(path_pieces, data)
          if cur_data.is_a?(Array) || cur_data.is_a?(Hash)
            puts JSON.pretty_generate(cur_data)
          else
            puts cur_data.inspect
          end
        end
      }
    }

    register(:helper, name: 'get_suggestions', parent: :json_value) { |path_pieces, data, print_children = false|
      if path_pieces.include?('*')
        nil
      else
        last_piece = path_pieces[-1]
        full_pieces = path_pieces[0..-2]
        cur_data = itr(full_pieces, data)
        if cur_data.is_a?(Array)
          l = (0...cur_data.count).to_a.map(&:to_s).natural_sort
          if last_piece.nil? || last_piece == ''
            l
          elsif l.include?(last_piece) && print_children
            get_suggestions(path_pieces + [nil], data)
          else
            l.select { |li| li.to_s.start_with?(last_piece) }
          end
        elsif cur_data.is_a?(Hash)
          l = cur_data.keys.natural_sort
          if last_piece.nil? || last_piece == ''
            l
          elsif l.include?(last_piece) && print_children
            get_suggestions(path_pieces + [nil], data)
          else
            l.select { |li| li.to_s.start_with?(last_piece) }
          end
        else
          nil
        end
      end
    }

    register(:helper, name: 'itr', parent: :json_value) { |path_pieces, cur_data|
      if path_pieces.nil? || path_pieces.empty?
        cur_data
      else
        piece = path_pieces[0]
        sub_pieces = path_pieces[1..-1]
        is_array = cur_data.is_a?(Array)
        if is_array
          if piece == '*'
            cur_data.map { |v| itr(sub_pieces, v) }
          else
            piece = piece.to_i
            if piece.abs >= cur_data.count
              cur_data
            else
              itr(sub_pieces, cur_data[piece])
            end
          end
        elsif cur_data.is_a?(Hash)
          if piece == '*'
            cur_data.map { |_, v| itr(sub_pieces, v) }
          else
            if cur_data.key?(piece)
              itr(sub_pieces, cur_data[piece])
            else
              cur_data
            end
          end
        else
          cur_data
        end
      end
    }
  end
end