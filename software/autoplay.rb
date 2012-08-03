#!/usr/bin/env ruby

def parse_ini(ini)
  cfg_hash = {}
  ini = ini.split(/\[([^\]]+)\]/)[1..-1]
  ini.inject([]) {|group, field|
    group << field
    if group.length == 2
      cfg_hash[group[0]] = group[1].sub(/^\s+/,'').sub(/\s+$/,'')
      group.clear
    end
    group
  }
  cfg_hash.dup.each { |var_key, var_val|
    tvlist = var_val.split(/[\r\n]+/)
    cfg_hash[var_key] = tvlist.inject({}) { |hash, val|
      k, v = val.split(/=/)
      hash[k]=v
      hash
    }
  }

  cfg_hash
end

def logger(str)
  $stderr.puts Time.now.strftime("%Y/%m/%d %H:%M:%S.%3N") + '>>    ' + str
end

require 'pathname'
work_dir = Pathname.new(Dir.getwd)
samegame_bin = File.expand_path('../player/bin/samegame.exe',__FILE__)
samegame_bin = Pathname.new(samegame_bin).relative_path_from(work_dir).to_s
config_dir = File.expand_path('../player/config/',__FILE__)
config_dir = Pathname.new(config_dir).relative_path_from(work_dir).to_s
evo_solver = File.expand_path('../solver/evolutionary/samegame.rb',__FILE__)
evo_solver = Pathname.new(evo_solver).relative_path_from(work_dir).to_s
bt_solver = File.expand_path('../solver/brute-force/bin/sg_bt_solver.exe',__FILE__)
bt_solver = Pathname.new(bt_solver).relative_path_from(work_dir).to_s

games = Hash[Dir[config_dir+'/*.cfg'].map do |file|
    ini = parse_ini(File.open(file,'r').read)
    path = Pathname.new(file)
    name = ini['general']['name'].to_s rescue path.basename.to_s[0..(-path.extname.length-1)]
    name = path.basename.to_s[0..(-path.extname.length-1)] if name == ''
    area = ini['game settings']['area'].to_i rescue 2
    solver_type = ini['solver']['type'] rescue nil
    [name, {:area => area, :solver_type => solver_type, :cfg => file}]
  end]

rounds = ARGV[0].to_i
game_name = ARGV[1].to_s

if games[game_name].nil?
  $stderr.puts 'SameGame Autoplay' + "\n" +
    'USAGE: ruby ' + __FILE__ + ' <rounds> <samegame>' + "\n" +
    'Supported samegames are:' + "\n" +
    games.keys.map{|name| '    - ' + name + "\n"}.join
else
  game = games[game_name]
  rounds.times do |i|
    logger("Autoplay | Round: #{(i+1)} of #{rounds}")
    game_field = (%x"#{samegame_bin} --config=#{game[:cfg]}").strip
    if game[:solver_type] == 'brute-force'
      logger('Autoplay | use brute-force solver')
      solution = %x"#{bt_solver} #{game[:area]} #{game_field}".split('SOLUTION:').last.gsub(/\n|\r/, '')
    else
      logger('Solve    | start, use evolutionary solver...')
      solution = %x"#{evo_solver} --finished --first --pop=100 --gen=40000 -h --area=#{game[:area]} #{game_field}"
    end

    if solution == ''
      logger('Solve    | No Solution found. Done')
      exit
    else
      logger('Solve    | done, solution: ' + "\n" + solution)
      %x"#{samegame_bin} --config=#{game[:cfg]} --solution=#{solution.dump}"
      $stderr.puts
      sleep 3
    end
  end
end
