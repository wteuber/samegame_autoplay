# This class represents the game_field and holds the evolutionary
# algorithm that solves the SameGame

class SameGame
  attr_accessor :matrix

  # initialize(params = {})
  #   parameters:
  #     game_field - rectangular Array of Array of Fixnum. The complete same game field
  #     colors - colors contained in the game, orderd by columns and rows
  #     history - enable or disable history functionality
  #     area - Number of fields that must be involved in a group
  #   return:
  #     nil
  #   meaning:
  #     sets up all necessary variables
  #def initialize(matrix = [[]], colors = [])
  def initialize(params = {})
    @matrix_backup = params[:game_field].nil? ? [[]] : params[:game_field]
    colors = params[:colors].nil? ? [] : params[:colors]
    @history = params[:history].nil? ? false : true
    @area = params[:area].nil? ? 2 : params[:area]
    reset!
    
    @col_count = @matrix_backup.length
    @row_count = @matrix_backup.first.length
    @false_matrix_backup = 1.upto(@col_count).map{1.upto(@row_count).map{false}}
    @empty_col = 1.upto(@row_count).map{0}
    init_colors (colors | ['red', 'blue', 'yellow', 'green', 'white', 'violet', 'lightblue'])
    @history = History.new(:colors => @color_count,
      :cols => @col_count,
      :rows => @row_count,
      :limit => 50000) if @history
    nil
  end
  
  # reset!
  #   parameters:
  #     none
  #   return:
  #     nil
  #   operation:
  #     Resets the game field, in order to use the game setup for another try.
  def reset!
    @matrix = Marshal.load(Marshal.dump(@matrix_backup))
    nil
  end

  # fitness(&block)
  #   parameters:
  #     &block - this code block calculates the actual fitness from the number
  #              of positions involved in one hit
  #   return:
  #     Proc
  #   meaning:
  #     !! The method fitness overwrites itself. It can only be set once !!
  def fitness(&block)
    self.class.send(:define_method, 'fitness', &block)
  end

  # fitness_of(individual)
  #   parameters:
  #     individual
  #   return:
  #     value of fitness of given individual
  #   side effects:
  #     Changes attributes 'clears' and 'max_hit_idx' of individual
  def fitness_of(individual)
    reset!
    fit_val = 0
    individual.G.each_with_index do |hit_index, idx|
      if @history
        possible_hits = @history.possible_hits(@matrix)
        if !possible_hits.nil? # known from history
          if possible_hits == 0
            individual.clears = true if finished?
            individual.max_hit_idx = idx - 1
            break
          end
          hit_index = (hit_index % possible_hits) + 1
          hit_checked = @history.hit_checked(@matrix, hit_index)
          if !hit_checked.nil? # known from history
            @hit_checked = @history.hit_checked(@matrix, hit_index)
          else
            possible_hits_count # to set @hit_checked
          end
        else
          possible_hits = possible_hits_count
          @history.add_possible_hits :matrix => @matrix, :possible_hits => possible_hits

          if possible_hits == 0
            individual.clears = true if finished?
            individual.max_hit_idx = idx - 1
            break
          end

          hit_index = (hit_index % possible_hits) + 1
          @history.add_hit_checked :matrix => @matrix, :hit_index => hit_index ,:hit_checked => @hit_checked
        end
      else
        possible_hits = possible_hits_count
        if possible_hits == 0
          individual.clears = true if finished?
          individual.max_hit_idx = idx - 1
          break
        end
        hit_index = (hit_index % possible_hits) + 1
      end
      fit_val += fitness(hit(hit_index))
      individual.clears = true if finished?
    end
    fit_val
  end



  
  ################################################################################
  # The following public methods are used for displaying purposes only.          #
  ################################################################################

  # phenotype_of(individual)
  #   This method is very similar to the method 'fitness_of'. The main purpose is
  #   to set attribues 'G_min' and 'P' of the given individual.
  #   parameters:
  #     individual
  #   return:
  #     phenotype according to the game field orientation.
  #   side effects:
  #     Changes attributes 'G_min' and 'P' of individual
  def phenotype_of(individual)
    @phenotype = []
    reset!
    individual.G_min = []
    individual.G.each_with_index do |u, i|
      hits_count = possible_hits_count
      break if hits_count == 0
      u = (u % hits_count) + 1
      individual.G_min[i] = u
      hit_for_phenotype(u)
    end
    individual.P = @phenotype
  end

  # play(individual, delay)
  #   parameters:
  #     individual
  #     delay - Time interval the program sleep between each hit.
  #   return:
  #     nil
  def play(individual, delay = 0.5)
    @phenotype = []
    reset!
    puts "\n" + self.to_s(:string_only => $setup.string_only) + "\n"
    individual.G[0..individual.max_hit_idx].each_with_index do |u, i|
      hits_count = possible_hits_count
      if hits_count > 0
        hit(u % hits_count + 1)
        puts self.to_s(:string_only => $setup.string_only) + "\n"
        sleep delay
      end
    end
    if individual.clears
      puts 'Cleared in '+(individual.max_hit_idx+1).to_s+' steps!'
    else
      puts 'Done after '+(individual.max_hit_idx+1).to_s+' steps!'
    end
    nil
  end

  def to_s(params = {})
    graph = params[:graph] || true
    append_string = params[:append_string] || false
    string_only = params[:string_only] || false
    fitness = params[:fitness] || false
    highlight = params[:highlight] || false
    highlighted_col = params[:highlighted_col] || -1
    #highlighted_row = params[:highlighted_row] || -1
    highlighted_row = params[:highlighted_row].nil? ? -1 : @row_count - params[:highlighted_row] - 1
    
    result = ""
    @matrix.transpose.reverse.each_with_index do |cols, row|
      cols.each_with_index do |val, col|
        if (val>=0) && ((col!=highlighted_col) || (row!=highlighted_row))
          result << (string_only ? (("%"+@color_count.to_s.length.to_s+"d") % val) : (@unix_color_hash[@color_hash[val]] +
              ( highlight ? @unix_color_hash['highlight'] : '') +
              val.to_s))
        else
          result << (@unix_color_hash[@color_hash[val.abs]] +
              @unix_color_hash['hit'] + 'X')
        end
        result << ' '
      end
      result << (string_only ? "\n" : (@unix_color_hash['standard']+"\n"))
    end if graph
    
    result << 'Fitness: ' + fitness.to_s + "\n" if fitness
    result << ('[[' + @matrix.map{|cols| cols*','}*"],[" + ']]') if append_string

    result
  end


  #  private
  
  #    #   hittable?(params)
  #    #     parameters:
  #    #       col - the column (index) to be checked
  #    #       row - the row (index) to be checked
  #    #     return:
  #    #       boolean
  #    #     meaning:
  #    #       whether a given position can be hit (true) or not (false)
  #    def hittable?(params)
  #      col = params[:col] || 0
  #      row = params[:row] || 0
  #      check = @matrix[col][row]
  #      return false if check <= 0
  #      check_east = @matrix[col+1][row] if ((col+1) < @col_count)
  #      return true if (check == check_east)
  #      check_south = @matrix[col][row+1]if ((row+1) < @row_count)
  #      return true if (check == check_south)
  #      check_west = @matrix[col-1][row] if ((col-1) >=0 )
  #      return true if (check == check_west)
  #      check_north = @matrix[col][row-1] if ((row-1) >= 0)
  #      return true if (check == check_north)
  #      return false
  #    end
  
  # hittable?(params)
  #   parameters:
  #     col - the column (index) to be checked
  #     row - the row (index) to be checked
  #     size - least number of positions an area needs to have in order to be hittable, default:2
  #     reset - set to false, if '@hittable' should not be reset, default: true
  #   return:
  #     boolean
  #   meaning:
  #     whether a given position can be hit (true) or not (false)
  def hittable?(params)
    col = params[:col]
    row = params[:row]
    reset = params[:reset].nil? ? true : params[:reset]

    return false if @matrix[col][row] <= 0
    if reset
      @hittable = 0
      @hittable_checked = Marshal.load(Marshal.dump(@false_matrix_backup))
      params.merge! :reset => false
    end
    @hittable_checked[col][row] = 1
    @hittable += 1

    return true if @hittable >= @area
    check_east  = hittable?(params.merge! :col => col+1) if ((col+1) < @col_count) && (!@hittable_checked[col+1][row]) && (@matrix[col][row] == @matrix[col+1][row])
    return true if check_east
    check_south = hittable?(params.merge! :row => row+1) if ((row+1) < @row_count) && (!@hittable_checked[col][row+1]) && (@matrix[col][row] == @matrix[col][row+1])
    return true if check_south
    check_west  = hittable?(params.merge! :col => col-1) if ((col-1) >= 0)         && (!@hittable_checked[col-1][row]) && (@matrix[col][row] == @matrix[col-1][row])
    return true if check_west
    check_north = hittable?(params.merge! :row => row-1) if ((row-1) >= 0)         && (!@hittable_checked[col][row-1]) && (@matrix[col][row] == @matrix[col][row-1])
    return true if check_north
    return false
  end



  # mark_involed_positions(col, row, hit_index)
  #   parameters:
  #     col - the column of a position involved in a hittable field
  #     row - the row of a position involved in a hittable field
  #     hit_index - the index number of the current hit
  #   return: nil
  #   operation:
  #     marks all positions of a hittable field from @matrix into @hit_checked
  #     including the position given by the parameters col and row.
  def mark_involed_positions(col, row, hit_index)
    @hit_checked[col][row] = hit_index
    mark_involed_positions(col+1, row, hit_index) if ((col+1) < @col_count) && (!@hit_checked[col+1][row]) && (@matrix[col][row] == @matrix[col+1][row])
    mark_involed_positions(col, row+1, hit_index) if ((row+1) < @row_count) && (!@hit_checked[col][row+1]) && (@matrix[col][row] == @matrix[col][row+1])
    mark_involed_positions(col-1, row, hit_index) if ((col-1) >= 0)         && (!@hit_checked[col-1][row]) && (@matrix[col][row] == @matrix[col-1][row])
    mark_involed_positions(col, row-1, hit_index) if ((row-1) >= 0)         && (!@hit_checked[col][row-1]) && (@matrix[col][row] == @matrix[col][row-1])
    nil
  end

  def finished?
    (@matrix[0][0] == 0)
  end

  def possible_hits_count
    hit_index = 0
    @hit_checked = Marshal.load( Marshal.dump( @false_matrix_backup ) )
    @matrix.each_with_index do |rows, col|
      rows.each_with_index do |val, row|
        if (!@hit_checked[col][row]) && hittable?(:col => col, :row => row)
          mark_involed_positions(col, row, (hit_index+=1))
          #puts self.to_s :highlight => true, :highlighted_col => col, :highlighted_row => row
        end
      end
    end
    hit_index
  end

  def hit(hit_idx)
    removed_pos = 0
    @hit_checked.each_with_index do |rows, col|
      rows.each_with_index do |current_hit_index, row|
        if current_hit_index == hit_idx
          removed_pos +=1
          @matrix[col][row] = 0
        end
      end
      tmp_rows = @matrix[col].reject{|row| row == 0}
      @matrix[col] = tmp_rows + 1.upto(@row_count - tmp_rows.length).map{0}
    end

    tmp_matrix = @matrix.reject{|cols| cols[0] == 0}
    @matrix = tmp_matrix + 1.upto(@col_count - tmp_matrix.length).map{Marshal.load(Marshal.dump(@empty_col))}
    removed_pos
  end

  def hit_for_phenotype(hit_idx)
    done = false
    removed_pos = 0
    @hit_checked.each_with_index do |rows, col|
      rows.each_with_index do |current_hit_index, row|
        if current_hit_index == hit_idx
          unless done
            @phenotype << [col,row]
            done = true
          end
          removed_pos +=1
          @matrix[col][row] = 0
        end
      end
      tmp_rows = @matrix[col].reject{|row| row == 0}
      @matrix[col] = tmp_rows + 1.upto(@row_count - tmp_rows.length).map{0}
    end

    tmp_matrix = @matrix.reject{|cols| cols[0] == 0}
    @matrix = tmp_matrix + 1.upto(@col_count - tmp_matrix.length).map{Marshal.load(Marshal.dump(@empty_col))}
    removed_pos
  end


  def init_colors(default_colors = ['red', 'blue', 'yellow', 'green', 'white', 'violet', 'lightblue'])
    @unix_color_hash = {}
    @unix_color_hash['standard'] = "\033[0m\033[37m\033[40m"
    @unix_color_hash['hit'] = "\033[1m"

    @unix_color_hash['highlight'] = "\033[1m"
    @unix_color_hash['black'] = "\033[0m\033[30m\033[40m"
    
    @unix_color_hash['red'] = "\033[0m\033[31m\033[41m"
    @unix_color_hash['green'] = "\033[0m\033[32m\033[42m"
    @unix_color_hash['yellow'] = "\033[0m\033[33m\033[43m"
    @unix_color_hash['blue'] = "\033[0m\033[34m\033[44m"
    @unix_color_hash['violet'] = "\033[0m\033[35m\033[45m"
    @unix_color_hash['lightblue'] = "\033[0m\033[36m\033[46m"
    @unix_color_hash['white'] = "\033[0m\033[37m\033[47m"

    
    color_numbers = []
    @matrix.each do |col|
      color_numbers |= col
    end
    @color_hash ={}
    @color_count = color_numbers.length
    if default_colors.length >= @color_count
      color_numbers.each_with_index do |color, idx|
        @color_hash[color] = default_colors[idx]
      end
    end
    @color_hash[0] = 'black'
    nil
  end
end