require 'rubygems'
require 'sinatra'

set :environment, :production

require 'jsmon.rb'
run Sinatra::Application
