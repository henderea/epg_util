require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class ExtractWorkResult
    extend Plugin

    register :command, id: :work_result, parent: nil, name: 'work_result', short_desc: 'work-result SUBCOMMAND ARGS...', desc: 'operate on work results'

    register(:command, id: :work_result_path, parent: :work_result, name: 'path', short_desc: 'path', desc: 'print out the path of the current file') { puts __FILE__ }

    register(:command, id: :work_result_extract, parent: :work_result, name: 'extract', short_desc: 'extract INPUT_FILE [OUTPUT_FILE]', desc: 'extract workflow results from a file') { |input, output = nil|
      printing = false
      ind = 0
      file = output && File.open(output, 'r+')
      File.open(input).each { |l|
        ind += 1
        line = l.chomp
        if line.start_with?('}') && printing
          printing = false
          (file || STDOUT).puts "#{ind}==> #{line}\n\n#{'=' * 100}\n\n"
        end
        printing = true if line.end_with?('{') && line.include?('work_result')
        (file || STDOUT).puts "#{ind}==> #{line}" if printing
      }
      file.close if file
    }
  end
end