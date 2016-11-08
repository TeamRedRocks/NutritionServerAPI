require 'rubygems'
require 'daemons'

pwd = File.dirname(File.expand_path(__FILE__))
fpath = pwd + "/nutritionapp.rb"

Daemons.run_proc('nutritionapp', :log_output=>true) do
    exec "ruby #{fpath}"
end