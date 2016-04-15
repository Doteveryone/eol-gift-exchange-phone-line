# config.ru
$stdout.sync = true

require 'sinatra'

require './respond'

run Sinatra::Application
