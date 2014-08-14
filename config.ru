require 'rubygems'
require 'bundler'

Bundler.require

require 'dotenv'
Dotenv.load

require './gifbot.rb'
run GifBot.new
