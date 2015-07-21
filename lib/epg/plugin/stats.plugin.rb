require 'everyday-plugins'
include EverydayPlugins
require 'everyday-cli-utils'
EverydayCliUtils.import :histogram, :kmeans, :maputil
require 'io/console'
module EpgUtil
  class Stats
    extend Plugin

    register(:command, id: :path_stats, parent: :path, name: 'stats', aliases: %w(stat), short_desc: 'stats', desc: 'print out the path of the file for the stats module') { puts __FILE__ }

    register :command, id: :stats, parent: nil, name: 'stats', aliases: %w(stat), short_desc: 'stats SUBCOMMAND ARGS...', desc: 'a set of statistics-related operations'

    register(:helper, name: 'get_data', parent: :stats) {
      data = []

      if options[:file].nil?
        val = nil
        i   = 0
        begin
          begin
            val = gets.chomp
            if val.length > 0
              data[i] = val.to_f
              i       += 1
            end
          rescue
            # ignored
          end
        end until val.nil? || val.length <= 0 || $stdin.eof?
      else
        if File.exist?(options[:file])
          data = IO.readlines(options[:file]).filtermap { |v|
            begin
              f = v.chomp
              f.length == 0 || (f =~ /^\d+(\.\d+)?$/).nil? ? false : f.to_f
            rescue
              false
            end
          }
        else
          puts "File '#{options[:file]}' does not exist!"
          exit 1
        end
      end
      data
    }

    register(:command, id: :stats_histogram, parent: :stats, name: 'histogram', aliases: %w(hist), short_desc: 'histogram', desc: 'create a histogram in the terminal') {
      data = get_data

      rows, cols = IO.console.winsize

      ks = options[:k_value].nil? ? data.nmeans : data.kmeans(options[:k_value])

      puts data.histogram(ks, options[:width] || cols, options[:height] || rows - 3)
    }

    register :flag, name: :file, parent: :stats_histogram, aliases: %w(-f), type: :string, desc: 'use a file instead of stdin'
    register :flag, name: :k_value, parent: :stats_histogram, aliases: %w(-k), type: :numeric, desc: 'use a specific k value instead of n-means'
    register :flag, name: :width, parent: :stats_histogram, aliases: %w(-w), type: :numeric, desc: 'specify a width for the histogram'
    register :flag, name: :height, parent: :stats_histogram, aliases: %w(-h), type: :numeric, desc: 'specify a height for the histogram'

    register(:command, id: :stats_outliers, parent: :stats, name: 'outliers', aliases: %w(out), short_desc: 'outliers', desc: 'calculate the outliers of a set of numbers') {
      data = get_data

      options[:sensitivity] = 0.5 if options[:sensitivity].nil?

      options[:delimiter] = ', ' unless options[:one_per_line] || options[:delimiter]

      ol = data.outliers(options[:sensitivity], options[:k_value]).sort

      puts ol.join("#{options[:delimiter]}#{options[:one_per_line] ? "\n" : ''}")
    }

    register :flag, name: :file, parent: :stats_outliers, aliases: %w(-f), type: :string, desc: 'use a file instead of stdin'
    register :flag, name: :one_per_line, parent: :stats_outliers, aliases: %w(-1), type: :boolean, desc: 'put each outlier on a separate line'
    register :flag, name: :delimiter, parent: :stats_outliers, aliases: %w(-d), type: :string, desc: 'use a specific delimiter to separate the outliers'
    register :flag, name: :sensitivity, parent: :stats_outliers, aliases: %w(-s), type: :numeric, desc: 'use a specific sensitivity level (0-1)'
    register :flag, name: :k_value, parent: :stats_outliers, aliases: %w(-k), type: :numeric, desc: 'use a specific k value instead of n-means'

    register(:command, id: :stats_means, parent: :stats, name: 'means', aliases: %w(nmeans kmeans), short_desc: 'means', desc: 'calculate the n-means or k-means of a set of numbers') {
      data = get_data

      options[:delimiter] = ', ' unless options[:one_per_line] || options[:delimiter]

      ks = options[:k_value].nil? ? data.nmeans : data.kmeans(options[:k_value])

      puts ks.join("#{options[:delimiter]}#{options[:one_per_line] ? "\n" : ''}")
    }

    register :flag, name: :file, parent: :stats_means, aliases: %w(-f), type: :string, desc: 'use a file instead of stdin'
    register :flag, name: :one_per_line, parent: :stats_means, aliases: %w(-1), type: :boolean, desc: 'put each outlier on a separate line'
    register :flag, name: :delimiter, parent: :stats_means, aliases: %w(-d), type: :string, desc: 'use a specific delimiter to separate the outliers'
    register :flag, name: :k_value, parent: :stats_means, aliases: %w(-k), type: :numeric, desc: 'use a specific k value instead of n-means'
  end
end