require 'json'
require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class JsonValue
    extend Plugin

    register(:command, id: :path_json_value, parent: :path, name: 'json_value', short_desc: 'json-value', desc: 'print out the path of the file for the json value extractor module') { puts __FILE__ }

    register(:command, id: :json_value, parent: nil, name: 'json_value', short_desc: 'json-value filename path', desc: 'extract a value from a json file', long_desc: <<EOS) { |filename, path|
Extract a value from a JSON file.  Use the format a->b->c to get root[a][b][c]
EOS
      data = JSON.parse(IO.read(File.expand_path(filename)))
      path_pieces = path.split(/->/)
      cur_data = itr(path_pieces, data)
      if cur_data.is_a?(Array) || cur_data.is_a?(Hash)
        puts JSON.pretty_generate(cur_data)
      else
        puts cur_data.inspect
      end
    }

    register(:helper, name: 'itr', parent: nil) { |path_pieces, cur_data|
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
    }
  end
end