require 'sinatra'
require 'twilio-ruby'
require 'dotenv'

Dotenv.load

get '/' do
  content_type 'text/xml'

  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, you are using a service which lets you send audio postcards.'
    r.Say 'Today’s theme is Places. Think of a story you can tell someone about a specific place.'
    r.Record maxlength: 30, action: '/place', method: 'get', transcribe: true, transcribeCallback: '/place-transcription', playBeep: false
  end.text
end

get '/place' do
  content_type 'text/xml'
  puts params['RecordingUrl']
  Twilio::TwiML::Response.new do |r|
    r.Say params['RecordingUrl']
  end.text
end

post 'place-transcription' do
  content_type 'text/xml'
  puts params['TranscriptionText']
end
