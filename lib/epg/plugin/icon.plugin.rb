require 'fileutils'
require 'fastimage_resize'
require 'everyday-plugins'
include EverydayPlugins
module EpgUtil
  class Icon
    extend Plugin

    register(:command, id: :path_icon, parent: :path, name: 'icon', short_desc: 'icon', desc: 'print out the path of the file for the icon utility module') { puts __FILE__ }

    register :command, id: :icon, parent: nil, name: 'icon', short_desc: 'icon SUBCOMMAND ARGS...', desc: 'run some icon utilities'

    register(:command, id: :icon_generator, parent: :icon, name: 'generator', aliases: %w(gen icns), short_desc: 'generator [input_file="Icon.png" [output_file="Icon.icns"]]', desc: 'generate a multi-resolution icns file') { |input_file = 'Icon.png', output_file = 'Icon.icns'|
      sizes = [512, 256, 128, 32, 16]
      folder = '/tmp/Icon.iconset'
      FileUtils.mkdir_p(folder)

      puts "\nGenerating sizes for image: #{input_file}\n"
      sizes.each do |size|
        # Make the @2x image
        FastImage.resize(input_file, size * 2, size * 2, :outfile => "#{folder}/icon_#{size}x#{size}@2x.png")

        # Make the regular image
        FastImage.resize(input_file, size, size, :outfile => "#{folder}/icon_#{size}x#{size}.png")
      end

      unless File.exist?('/Applications/ImageOptim.app')
        puts 'Downloading ImageOptim.app'
        system('curl -o /tmp/ImageOptim.tbz2 "https://imageoptim.com/ImageOptim.tbz2"')
        puts 'Extracting ImageOptim.app'
        `tar -j -x -f /tmp/ImageOptim.tbz2 -C /tmp/`
        puts 'Installing ImageOptim.app to /Applications/ImageOptim.app'
        `mv /tmp/ImageOptim.app /Applications/ImageOptim.app`
        puts 'Deleting download'
        `rm -rf /tmp/ImageOptim.tbz2`
      end

      puts 'Optimizing images... please wait.'
      `/Applications/ImageOptim.app/Contents/MacOS/ImageOptim 2>/dev/null #{folder}/icon_*x*.png`

      puts 'Generating iconset file.'
      `iconutil -c icns -o #{output_file} #{folder}`

      puts 'Removing temporary files'
      `rm -rf #{folder}`

      puts "Your file is called: #{output_file}\nDone!"
    }

    register(:command, id: :icon_favicon, parent: :icon, name: 'favicon', aliases: %w(fav gen_fav gen_favicon), short_desc: 'favicon [input_file="Icon.png" [output_file="favicon.ico"]]', desc: 'generate a multi-resolution favicon') { |input_file = 'Icon.png', output_file = 'favicon.ico'|
      sizes = [16, 32, 48, 57, 64, 72, 96, 110, 114, 120, 128, 144, 152, 180, 192, 195, 228, 310]
      puts 'Generating favicon file'
      `convert #{input_file} -background transparent #{sizes.map { |s| "\\( -clone 0 -resize #{s}x#{s} \\)" }.join(' ')} -delete 0 -alpha on -depth 32 #{output_file}`
      puts "Your file is called: #{output_file}\nDone!"
    }
  end
end