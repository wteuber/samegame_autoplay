class Setup
  attr_accessor :clipboard, :generate, :cols, :rows, :colors, :area, :finished,
    :first, :done, :population, :gen_idx, :generation, :mutate_prob, :recombine_prob,
    :history, :output, :string_only, :play, :game_field

  def initialize(argv = [])
    valid_arg_regexps = [
      /\A^-c$/,
      /\A^--clip$/,
      /\A^-g$/,
      /\A^--generate$/,
      /\A^-o$/,
      /\A^--output$/,
      /\A^--finished$/,
      /\A^--first$/,
      /\A^--cols=[0-9][0-9]*$/,       #must be position 8 in array!
      /\A^--rows=[0-9][0-9]*$/,       #must be position 9 in array!
      /\A^--colors=[0-9][0-9]*$/,     #must be position 10 in array!
      /\A^--pop=[0-9][0-9]*$/,        #must be position 11 in array!
      /\A^--gen=[0-9][0-9]*$/,        #must be position 12 in array!
      /\A^\[\[(\[|\]|,|\d| )*\]\]$/,  #must be position 13 in array!
      /\A^--area=[0-9][0-9]*$/,       #must be position 14 in array!
      /\A^--mprob=[0-9][0-9]*$/,      #must be position 15 in array!
      /\A^--rprob=[0-9][0-9]*$/,      #must be position 16 in array!
      /\A^--string$/,
      /\A^-s$/,
      /\A^--history$/,
      /\A^-h$/,
      /\A^--play$/,
      /\A^-p$/
    ]

    argv.each do |arg|
      valid = false
      valid_arg_regexps.each do |match|
        valid ||= !(arg =~ match).nil?
      end
      unless valid
        puts 'samegame: unknown option: ' + arg.to_s
        puts
        puts 'valid arguments are:'
        puts ' -c, --clip, -g, --generate, --cols=[0..9]+, --rows=[0..9]+,'
        puts ' --colors=[0..9]+, --area=[0..9]+, --finished, --first,'
        puts ' --pop=[0..9]+, --gen=[0..9]+, --mprob=0-100, --rprob=0-100,'
        puts ' --history, -o, --output, -s, --string, -p, --play'
        puts
        puts 'For help run samegame without arguments.'
        exit
      end
    end
    @clipboard = (argv.member?('-c') || argv.member?('--clip'))
    @generate = (argv.member?('-g') || argv.member?('--generate'))
    @output =  (argv.member?('-o') || argv.member?('--output'))
    @play =  (argv.member?('-p') || argv.member?('--play'))
    @history = (argv.member?('-h') || argv.member?('--history'))
    @string_only = (argv.member?('-s') || argv.member?('--string'))
    @finished =  (argv.member?('--finished'))
    @first =  (argv.member?('--first'))
    @done = false
    @cols = argv.reject{|arg| (arg =~ valid_arg_regexps[8]) != 0}.first.split(/=/).last.to_i rescue 10
    @rows = argv.reject{|arg| (arg =~ valid_arg_regexps[9]) != 0}.first.split(/=/).last.to_i rescue 10
    @colors = argv.reject{|arg| (arg =~ valid_arg_regexps[10]) != 0}.first.split(/=/).last.to_i rescue 3
    @string_only = true if @colors > 7
    @population = argv.reject{|arg| (arg =~ valid_arg_regexps[11]) != 0}.first.split(/=/).last.to_i rescue 10
    #@gen_idx = Math.sqrt(@population).to_i-1
    @gen_idx = (@population.to_f / 10).ceil-1
    @generation = argv.reject{|arg| (arg =~ valid_arg_regexps[12]) != 0}.first.split(/=/).last.to_i rescue 5
    @area = argv.reject{|arg| (arg =~ valid_arg_regexps[14]) != 0}.first.split(/=/).last.to_i rescue 2
    @mutate_prob = argv.reject{|arg| (arg =~ valid_arg_regexps[15]) != 0}.first.split(/=/).last.to_f/100 rescue 1.0
    @mutate_prob = 1.0 if @mutate_prob > 1.0
    @recombine_prob = argv.reject{|arg| (arg =~ valid_arg_regexps[16]) != 0}.first.split(/=/).last.to_f/100 rescue 1.0
    @recombine_prob = 1.0 if @recombine_prob > 1.0
    if argv.reject{|arg| (arg =~ valid_arg_regexps[13]) != 0}.empty?
      if @clipboard
        @game_field = eval(Clipboard.data) if Clipboard.data =~ valid_arg_regexps[13]
      else
        if @generate
          @game_field = SameGameHelper::generate_matrix(:cols => @cols, :rows => @rows, :colors => @colors)
        else
          puts 'samegame: no <game_field> option given'
          puts
          puts 'valid arguments are:'
          puts ' -c, --clip, -g, --generate, --cols=[0..9]+, --rows=[0..9]+,'
          puts ' --colors=[0..9]+, --area=[0..9]+, --finished, --first,'
          puts ' --pop=[0..9]+, --gen=[0..9]+, --mprob=0-100, --rprob=0-100,'
          puts ' --history, -o, --output, -s, --string, -p, --play'
          puts
          puts 'For help run samegame without arguments.'
          exit
        end
      end
    else
      @game_field = eval(argv.reject{|arg| (arg =~ valid_arg_regexps[13]) != 0}.first) rescue [[]]
      @cols = @game_field.length
      @rows = @game_field.first.length
    end
  end
end