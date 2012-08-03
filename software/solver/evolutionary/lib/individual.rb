# This class represents an individual.

class Individual
  attr_accessor :G, :G_min, :P, :F, :clears, :max_hit_idx, :max_hit_count
  def initialize(params = {})
    @max_hit_count = params[:max_hit_count] #|| 2**16
    @G = params[:genotype] || 1.upto(@max_hit_count).map{rand(@max_hit_count)}
    @G_min = nil
    @P = nil
    @F = 0
    @clears = false
    @max_hit_idx = @max_hit_count
  end

  def <=>(individual)
    comp_idx = [@max_hit_idx, individual.max_hit_idx].max
    @G[0..comp_idx] <=> individual.G[0..comp_idx]
  end

  def ==(individual)
    comp_idx = [@max_hit_idx, individual.max_hit_idx].max
    @G[0..comp_idx] == individual.G[0..comp_idx]
  end

  def mutate!
#    # Shuffle Mutation:
#    @G.shuffle!
#    # 1-Point-Mutation:
#    @G[rand(@max_hit_idx)] = rand(@max_hit_count)
    # random complete Mutation:
    @G = 1.upto(@max_hit_count).map{rand(@max_hit_count)}
    @clears = false
    @max_hit_idx = @max_hit_count
    self
  end

  def one_point_crossover!(individual, idx = 0)
    @clears = false
    @max_hit_idx = @max_hit_count
    @G = @G[0..idx] + individual.G[(idx+1)..@max_hit_count]
    self
  end

  def set_output_attributes(same_game)
      same_game.phenotype_of(self)
      nil
  end

  def to_s
    'G0   : [' + @G[0..@max_hit_idx]*',' + ']' + "\n" +
      (@G_min.nil? ? '' : 'G1   : [' + @G_min[0..@max_hit_idx]*',' + ']' + "\n") +
      (@P.nil? ? '' : 'P    : ' + '[[' + @P.map{|rows| rows*','}*'],[' + ']]' + "\n") +
      'F    : ' + @F.to_s + "\n"+ 'clear: ' + @clears.to_s + "\n"
  end
end
