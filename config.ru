require 'rubygems'
require 'sinatra'
# debugger
require 'pry-remote'

require File.join(File.dirname(__FILE__), 'lib', 'server')

run CommonplaceServer