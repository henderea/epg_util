require 'everyday-plugins'
include EverydayPlugins

class Integer
  def factorial
    (1..(zero? ? 1 : self)).inject(:*)
  end
end

module EpgUtil
  class AppInfo
    attr_accessor :id, :name, :connections

    def initialize(id, name)
      @id          = id
      @name        = name
      @connections = []
    end

    # @param [*AppInfo] other
    def link(*others)
      others.each { |other|
        unless other.id == self.id
          self.connections << other.id
          self.connections = self.connections.uniq
          other.connections << self.id
          other.connections = other.connections.uniq
        end
      }
    end

    def to_s
      self.name
    end
  end
  class SpacesFinder
    def initialize(ids, space_links, item_links)
      @apps = {}
      ids.each { |k, v| @apps[k.to_sym] = AppInfo.new(k.to_sym, v.to_s) }
      @grid_links = eval_grid_links(space_links)
      item_links.each { |l|
        i1, i2 = l.scan(/^(\w+)--(\w+)$/)[0]
        a1     = @apps[i1.to_sym]
        a2     = @apps[i2.to_sym]
        unless a1 && a2
          puts "Invalid item link '#{l}'"
          exit 1
        end
        a1.link(a2)
      }
    end

    def eval_grid_link(n, v, o, i, w, h, cnt, r, c)
      if v == 'r'
        (((r + ((o == '+' ? 1 : -1) * n)) % h) * w) + c
      elsif v == 'c'
        ((r + ((o == '+' ? 1 : -1) * n)) % w) + (r * w)
      else
        (i + ((o == '+' ? 1 : -1) * n)) % cnt
      end
    end

    def eval_grid_links(grid_links)
      arr = []
      grid_links.each { |l|
        v, o, n = l.scan(/^([irc])([+\-])(\d+)$/)[0]
        unless v && o && n
          puts "Invalid space link '#{l}'"
          exit 1
        end
        n = n.to_i
        arr << ->(i, w, h, cnt) { eval_grid_link(n, v, o, i, w, h, cnt, i / w, i % w) }
      }
      arr
    end

    def to_table(sc_inds, width, height)
      table       = []
      sc_inds_rev = sc_inds.invert
      (0...height).each { |r|
        table[r] = []
        (0...width).each { |c|
          ind         = r * width + c
          table[r][c] = @apps[sc_inds_rev[ind]] || ''
        }
      }
      table
    end

    def print_table(table)
      table_inv      = table.transpose
      max_col_widths = []
      table_inv.each_with_index { |v, i| max_col_widths[i] = v.map { |v2| v2.to_s.length }.max }
      sep     = max_col_widths.map { |v| '-' * (v+2) }
      sep_str = "+#{sep.join('+')}+"
      table.each { |r|
        puts sep_str
        puts "| #{r.map.with_index { |v, i| v.to_s.center(max_col_widths[i]) }.join(' | ') } |"
      }
      puts sep_str
    end

    def itr(dc_ind, sc, sc_inds, width, height)
      dcim = @apps.keys
      if dc_ind >= dcim.count
        cur = sc_inds.values.map.with_index { |v, i| v * (sc.count - (i + 1)).factorial / (sc.count - dcim.count).factorial }.inject(:+) + 1
        max = sc.count.factorial / (sc.count - dcim.count).factorial
        print "\r\e[2K@@#{width}x#{height} => #{cur} of #{max} (#{'%.3f' % ((cur.to_f / max.to_f) * 100.0)}%)"
        matches = true
        sc_inds.each { |k, v|
          sci     = sc[v]
          dci     = @apps[k].connections
          matches = dci.all? { |k2| sci.include?(sc_inds[k2]) }
          break unless matches
        }
        if matches
          puts "\n#{'=' * 25}\n\n"
          print_table(to_table(sc_inds, width, height))
          puts "\n\n#{'=' * 25}"
        end
      else
        (0...sc.count).each { |i|
          unless sc_inds.values.include?(i)
            sc_inds2               = sc_inds.clone
            sc_inds2[dcim[dc_ind]] = i
            itr(dc_ind + 1, sc, sc_inds2, width, height)
          end
        }
      end
    end

    def run
      (1..@apps.count).each { |width|
        (1..@apps.count).each { |height|

          print "\r\e[2K@@#{width}x#{height}"

          count = width * height

          space_connections = []

          (0...count).each { |i|
            # space_connections[i] = [(i - 1) % count, (i + 1) % count, (i - width) % count, (i + width) % count]
            space_connections[i] = @grid_links.map { |l| l.call(i, width, height, count) }
          }

          itr(0, space_connections, {}, width, height)
        }
      }
      puts
    end
  end

  class Spaces
    extend Plugin

    register(:command, id: :path_spaces, parent: :path, name: 'spaces', short_desc: 'spaces', desc: 'print out the path of the file for the spaces module') { puts __FILE__ }

    register(:command, id: :spaces, parent: nil, name: 'spaces', short_desc: 'spaces', desc: 'find all possible combinations of placements of linked items for a linked grid of spaces') {
      SpacesFinder.new(options[:ids], options[:space_links], options[:item_links]).run
    }

    register :flag, name: :ids, parent: :spaces, aliases: %w(-i), type: :hash, desc: 'specify the id mappings', required: true
    register :flag, name: :space_links, parent: :spaces, aliases: %w(-s), type: :array, desc: 'specify the space links (/[irc][+\-]\d+/)', required: true
    register :flag, name: :item_links, parent: :spaces, aliases: %w(-l), type: :array, desc: 'specify the item links (id1--id2)', required: true
  end
end