class History
  attr_accessor :color_count, :col_count, :row_count, :history_of_possible_hits, :history_of_hit_checked, :limit

  def initialize(params)
    @color_count = params[:colors] + 1
    @col_count = params[:cols]
    @row_count = params[:rows]
    @limit = params[:limit] || 500000

    @history_of_possible_hits = {}
    @history_of_hit_checked = {}
  end

  def add_possible_hits(params)
    matrix = params[:matrix]
    possible_hits = params[:possible_hits]
    @history_of_possible_hits[matrix_to_i(matrix)] = possible_hits
    @history_of_possible_hits = @history_of_possible_hits[1..@history_of_possible_hits.length] if @history_of_possible_hits.length > @limit
    self
  end

  def possible_hits(matrix)
    @history_of_possible_hits[matrix_to_i(matrix)]
  end

  def add_hit_checked(params)
    matrix = params[:matrix]
    hit_index = params[:hit_index]
    hit_checked = Marshal.load(Marshal.dump(params[:hit_checked]))
    @history_of_hit_checked[[matrix_to_i(matrix),hit_index]] = hit_checked
    @history_of_hit_checked = @history_of_hit_checked[1..@history_of_hit_checked.length] if @history_of_hit_checked.length > @limit
    self
  end

  def hit_checked(matrix, hit_index)
    Marshal.load(Marshal.dump(@history_of_hit_checked[[matrix_to_i(matrix),hit_index]]))
  end

  def matrix_to_i(matrix)
    if @color_count+1 <= 10
      res = Integer(matrix.reverse.transpose.reverse.to_s.gsub(/[ ,\[\]]/,''),(@color_count+1))
    else
      res = matrix
    end
    res
  end

  def restore_matrix(int_matrix)
    matrix = []
    temp_matrix = (int_matrix.to_s(@color_count+1)).split(//).reverse.map{|e|e.to_i}
    add_entries = (@col_count * @row_count) - (temp_matrix.length % @col_count) - temp_matrix.length
    temp_matrix += add_entries.times.map{0}

    (temp_matrix.length / @row_count).times do |col|
      matrix[col] = temp_matrix.take(@row_count)
      temp_matrix = temp_matrix.drop(@row_count)
    end
    matrix
  end
end