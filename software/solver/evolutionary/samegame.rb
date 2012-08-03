#!/usr/bin/env ruby

if ARGV.empty?
  puts 'Usage: samegame [OPTIONS] <game_field>'
  puts
  puts 'Options:'
  puts '  -c, --clip          Get <game_field> from Windows clipboard.'
  puts '                      Make sure you have a valid <game_field> string'
  puts '                      in your clipboard before.'
  puts '  -g, --generate      Generate a random <game_field>.'
  puts '  --cols=<colums>     Number of colums for generating a <game_field>.'
  puts '                      Will only be considered using -g option.'
  puts '                      default: 10'
  puts '  --rows=<rows>       Number of rows for generating <game_field>.'
  puts '                      Will only be considered using -g option.'
  puts '                      default: 10'
  puts '  --colors=<colors>   Number of colors for generating <game_field>.'
  puts '                      Will only be considered using -g option.'
  puts '                      default: 3'
  puts '  --area=<size>       Number of connected fields that can be hit.'
  puts '                      default: 2'
  puts '  --finished          Consider solutions that finish the game only.'
  puts '  --first             Stop after the first individual clears the game.'
  puts '                      If --finished is set, this solution is presented.'
  puts '  --pop=<population>  Size of population. default: 10'
  puts '  --gen=<generations> Number of generations. default: 5'
  puts '  --mprob=<percent>   Probability of Mutation. 0 for none, 100 for all.'
  puts '                      default: 100'
  puts '  --rprob=<percent>   Probability of Recombination. 0 for none, 100 for'
  puts '                      all. default: 100'
  puts '  -h, --history       Store results in memory. This may be RAM-consuming'
  puts '                      for a large <game_field>. Using this option the'
  puts '                      program may be starting slow. It is highly'
  puts '                      recommended for a great number of generations.'
  puts '  -o, --output        Prints <game_field> and the result of the'
  puts '                      calculation.'
  puts '  -s, --string        Prints any <game_field> as plain string instead of'
  puts '                      UNIX color-coded output.'
  puts '  -p, --play          Playback the solution'
  puts
  puts '<game_field>          Decription of a SameGame field setup.'
  puts '                      You must only use:'
  puts '                        - digits: 0 1 2 3 4 5 6 7 8 9'
  puts '                        - comma: ,'
  puts '                        - squared brackets: [  ]'
  puts '                      like: [[1,3,2,1],[3,1,1,2],[1,3,2,3],[1,2,3,2]]'
  puts
  puts 'If multiple <game_field> options are given, these are the priorities:'
  puts '  1. <game_field>     Get from argument list'
  puts '  2. -c               Get from Clipboard'
  puts '  3. -g               Generate according to cols/rows/colors options'
  puts
  puts 'Digits represent the color index. You should not use more colors than'
  puts 'there are fields in this SameGame setup. The first digit represents'
  puts 'the most left bottom position of the field. The first set of digits'
  puts 'represent the first column from bottom to top. The following sets of'
  puts 'digits decribe the following columns also from bottom to top. Do not use'
  puts 'whitespace in game field description.'
  puts '[[1,3,2,2],[3,1,1,2],[1,3,2,3],[1,2,3,2],[1,2,3,2]] means:'
  puts
  puts '  2  2  3  2  2'
  puts '  2  1  2  3  3'
  puts '  3  1  3  2  2'
  puts '  1  3  1  1  1'
  puts
  puts 'Samples:   ./samegame -g -o -p'
  puts '           ./samegame -g -o --gen=30 --pop=10 --cols=20 --rows=15 -h -s'
  puts '           ./samegame -o [[1,3,2,1],[3,1,1,2],[1,3,2,3],[1,2,3,2]]'
  puts
  puts 'Have fun (not) playing the SameGame ;-)'
  exit
end

#Make sure that paths are set correctly
require 'pathname'
work_dir = Pathname.new(Dir.getwd)
abs_path = File.expand_path("../lib/main.rb", __FILE__)
main_rb = Pathname.new(abs_path).relative_path_from(work_dir).to_s
system('ruby "' + main_rb + '" ' + ARGV*' ')
