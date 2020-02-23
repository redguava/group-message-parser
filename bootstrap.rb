require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

APP_ROOT = Pathname.new(File.expand_path(__dir__))

$LOAD_PATH.unshift(APP_ROOT.join('lib'))
