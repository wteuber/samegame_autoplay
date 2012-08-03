#require 'rubygems'

require File.expand_path('../same_game', __FILE__)
require File.expand_path('../history', __FILE__)
require File.expand_path('../same_game_helper', __FILE__)
require File.expand_path('../population', __FILE__)
require File.expand_path('../individual', __FILE__)
require File.expand_path('../setup', __FILE__)

$setup = Setup.new(ARGV)
def out(&block) STDERR.puts yield block if $setup.output end

#require 'win32/clipboard' if $setup.clipboard
#include Win32 if $setup.clipboard
