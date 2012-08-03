require 'time'

def scan log, from, to
  i = File.open(log,'r').read
  o = i.split("\n\n").map do |g|
    start = fin = 0
    g.split("\n").map do |line|
      elements = line.scan(/(\A2012\/[^\.]*)(.*$)/).flatten
      if line.include?(from)
        start = DateTime.strptime(elements[0], "%Y/%m/%d %H:%M:%S").to_time.to_f + (0.001 * elements[1][1..3].to_i)
      end
      if line.include?(to)
        fin = DateTime.strptime(elements[0], "%Y/%m/%d %H:%M:%S").to_time.to_f + (0.001 * elements[1][1..3].to_i)
      end
    end
    (fin - start).round 3
  end
end

def solve_times file
  scan file, '>>    Solve    | start', '>>    Solve    | done'
end

def parse_times file
  scan file, '>>    Parse    | start', '>>    Parse    | done'
end

def play_times file
  scan file, '>>    Play     | start', '>>    Play     | done'
end

def round_times file
  scan file, '>>    Autoplay | Round', '>>    Play     | done'
end

bso = solve_times 'bricks_breaking_1000.log'
kso = solve_times 'knugie_same_1000.log'

bpa = parse_times 'bricks_breaking_1000.log'
kpa = parse_times 'knugie_same_1000.log'

bpl = play_times 'bricks_breaking_1000.log'
kpl = play_times 'knugie_same_1000.log'

bro = round_times 'bricks_breaking_1000.log'
kro = round_times 'knugie_same_1000.log'


#Minimum
bso.min
kso.min
bpa.min
kpa.min
bpl.min
kpl.min
bro.min
kro.min

#Maximum
bso.max
kso.max
bpa.max
kpa.max
bpl.max
kpl.max
bro.max
kro.max

#Average:
(bso.inject(:+) / bso.length).round 3
(kso.inject(:+) / kso.length).round 3
(bpa.inject(:+) / bpa.length).round 3
(kpa.inject(:+) / kpa.length).round 3
(bpl.inject(:+) / bpl.length).round 3
(kpl.inject(:+) / kpl.length).round 3
(bro.inject(:+) / bro.length).round 3
(kro.inject(:+) / kro.length).round 3
