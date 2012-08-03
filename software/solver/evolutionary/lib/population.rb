# This class represents a population.

class Population
  attr_accessor :individuals
  def initialize(params = {})
    population = params[:population] || 1
    cols = params[:cols] || 5
    rows = params[:rows] || 5
    @individuals = []
    population.times do
      @individuals << Individual.new(:max_hit_count => ((cols*rows)/2))
    end
  end

  def to_s
    c = 0
    @individuals.map{|ind| (c+=1).to_s + '. ' + ind.to_s}*"\n"
  end

  def remove_unfinished!
    @individuals.sort!{|a,b| b.F <=> a.F}.reject!{|i| !i.clears}
  end

  def best_individual
    @individuals.sort{|a,b| b.F <=> a.F }.first
  end

  def calculate_fitness(same_game)
    @individuals.each do |individual|
      individual.F = same_game.fitness_of individual
#      out{ same_game.to_s(:fitness => individual.F) }
      out{'    ' + individual.F.to_s + (individual.clears ? ',clear' : '')}# + individual.max_hit_idx.to_s + '[' + individual.G_min[0..individual.max_hit_idx]*',' + ']' : '') }
      if $setup.first && individual.clears
        $setup.done = true
        break
      end

      #      should_remove = 151
      #      m = Marshal.load(Marshal.dump(same_game.matrix))
      #      removed = m.each_index{|idx| m[idx] = m[idx].count(0)}.each_index{|idx| (m[idx]= m[idx-1] + m[idx]) if idx >=1}.last
      #      individual.F = removed
      #      puts '    new F :' + removed.to_s
      #      if removed >= should_remove
      #        individual.F = 1.0/0
      #        $setup.done = true
      #        break
      #      end
    end
    nil
  end

  def next_generation
    res = Marshal.load(Marshal.dump(self))
    res.recombine!
    res.mutate!
    res
  end

  def recombine!
    #min_max_hit_idx = @individuals.min_by{|i| i.max_hit_idx}.max_hit_idx
    #right_parts = @individuals.uniq{|individual| individual.G[0..min_max_hit_idx]}.shuffle
    right_parts = @individuals.shuffle
    @individuals.each_with_index do |individual, idx|
      if ($setup.recombine_prob == 1.0) || (rand <= $setup.recombine_prob)
        individual.one_point_crossover!(right_parts[idx], rand(individual.max_hit_idx)/2) unless (individual == right_parts[idx])
      end
    end
  end

  def mutate!
    @individuals.each do |individual|
      if ($setup.mutate_prob == 1.0) || (rand <= $setup.mutate_prob)
        individual.mutate!
      end
    end
  end

  def merge(population)
    # select the best Sqrt(pop.length) of each population and some random others
    min_max_hit_idx = @individuals.min{|i,j| i.max_hit_idx <=> j.max_hit_idx}.max_hit_idx
    parents = @individuals.sort{|a,b| b.F <=> a.F }.uniq{|individual| individual.G[0..min_max_hit_idx]}
    parents.sort!{|a,b| (b.clears.to_s) <=> (a.clears.to_s)} if $setup.finished

    min_max_hit_idx = population.individuals.min{|i,j| i.max_hit_idx <=> j.max_hit_idx}.max_hit_idx
    children = population.individuals.sort{|a,b| b.F <=> a.F }.uniq{|individual| individual.G[0..min_max_hit_idx]}
    children.sort!{|a,b| (b.clears.to_s) <=> (a.clears.to_s)} if $setup.finished

    res = parents[0..$setup.gen_idx]
    res += children[0..$setup.gen_idx]
    
    rest_count = ($setup.population - ($setup.gen_idx+1)*2)
    res += (parents[$setup.gen_idx..$setup.population-1] + children[$setup.gen_idx..$setup.population-1]).shuffle[0..(rest_count-1)] unless rest_count <= 0
    res.sort{|a,b| b.F <=> a.F }
    res.sort!{|a,b| (b.clears.to_s) <=> (a.clears.to_s)} if $setup.finished
    res
  end

  def merge!(population)
    @individuals = merge(population)
  end
end
