require File.expand_path('../necessities', __FILE__)

population = Population.new :population => $setup.population,
  :cols => $setup.cols,
  :rows => $setup.rows
same_game = SameGame.new :game_field => $setup.game_field,
  :history => $setup.history,
  :area => $setup.area


#same_game.fitness{|positions| (positions-2)**2} # JS-SameGame
#same_game.fitness{|positions| positions*(positions+10)} # Mindjolt's Bricks Breaking
same_game.fitness{|positions| (positions*positions+2)*5} # Mindjolt's Cube Crasher

out{'START:'}
out{same_game.to_s(:string_only => $setup.string_only, :append_string => true)}

$setup.generation.times do |generation|
  out{ 'Generation:' + generation.to_s}
  out{ '  Parents:'}
  population.calculate_fitness same_game
  break if $setup.done

  out{ '  Children:'}
  children = population.next_generation
  children.calculate_fitness same_game
  population.merge!(children)
  break if $setup.done
end

population.remove_unfinished! if $setup.finished
best_individual = population.best_individual


if best_individual.nil?
  out{ 'no solution found'}
  Clipboard.set_data([]) if $setup.clipboard
else
  best_individual.set_output_attributes(same_game)
  #genotype0 = '[' + p.first.G[0..p.first.max_hit_idx]*',' + ']'
  genotype1 = '[' + best_individual.G_min[0..best_individual.max_hit_idx]*',' + ']'
  puts same_game.play(best_individual, 0.1) if $setup.play
  out{ 'Best Individual:'}
  out{ best_individual.to_s}
  out{ }
  print genotype1
  out{ }
  Clipboard.set_data(genotype1) if $setup.clipboard
end
