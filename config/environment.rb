# Hace require de los gems necesarios.
# Revisa: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'

require 'uri'
require 'pathname'

# Require gem of twitter
require 'twitter'
require 'yaml'

# Require gem of OAuth
require 'oauth'

require 'pg'
require 'active_record'
require 'logger'

require 'sinatra'
require "sinatra/reloader" if development?

require 'erb'

APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Configura los controllers y los helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'uploaders', '*.rb')].each { |file| require file }


# Configura la base de datos y modelos 
require APP_ROOT.join('config', 'database')
# Lo siguiente comentado ejecutaba la aplicacion para un usuario en particular en twitter con un archivo yml
# yaml = YAML.load(File.open("config/twitter.yml"))

# CLIENT = Twitter::REST::Client.new do |config|
#     config.consumer_key        = yaml["consumer_key"]
#     config.consumer_secret     = yaml["consumer_secret"]
#     config.access_token        = yaml["access_token"]
#     config.access_token_secret = yaml["access_token_secret"]
# end

env_config = YAML.load_file(APP_ROOT.join('config', 'twitter_public.yml'))


env_config.each do |key, value|
  ENV[key] = value
end

CLIENT= Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_KEY']
  config.consumer_secret = ENV['TWITTER_SECRET']
end

# lo siguiente la estructura del hash que debe ir en un
# archivo yml en la carpeta config recuerda cambiar consumer
#  key y secret por las respectivas que te da la app en apps.twitter.com

# ---
# TWITTER_KEY: 'consumer key'
# TWITTER_SECRET: 'consumer secret'