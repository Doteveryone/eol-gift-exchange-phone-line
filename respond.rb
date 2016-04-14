require 'sinatra'
require 'twilio-ruby'
require 'dotenv'

Dotenv.load

get '/' do
  content_type 'text/xml'

  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, this is an example of a program which uses Twilio.'
  end.text
end
