require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class Phone
    extend Plugin

    register(:command, id: :path_phone, parent: :path, name: 'phone', short_desc: 'phone', desc: 'print out the path of the file for the phone text module') { puts __FILE__ }

    register(:command, id: :phone, parent: nil, name: 'phone', short_desc: 'phone TEXT', desc: 'translate TEXT into phone digits') { |text|
      text = text.strip
      clean_text = text.upcase.gsub(/[^A-Z0-9]/, '')
      $stderr.puts "Invalid characters cleaned out.  New text: '#{clean_text}'" if clean_text.length != text.length
      new_text = clean_text
      new_text = new_text.gsub(/[A-C]/, '2')
      new_text = new_text.gsub(/[D-F]/, '3')
      new_text = new_text.gsub(/[G-I]/, '4')
      new_text = new_text.gsub(/[J-L]/, '5')
      new_text = new_text.gsub(/[M-O]/, '6')
      new_text = new_text.gsub(/[P-S]/, '7')
      new_text = new_text.gsub(/[T-V]/, '8')
      new_text = new_text.gsub(/[W-Z]/, '9')
      puts new_text
    }
  end
end