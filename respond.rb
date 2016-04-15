require 'sinatra'
require 'twilio-ruby'
require 'dotenv'
require 'sinatra/activerecord'

Dotenv.load

set :logging, true

class Story < ActiveRecord::Base
end

get '/' do
  content_type 'text/xml'

  Story.create(call_sid: params['CallSid'])

  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, you are using a service which lets you send audio postcards.'
    r.Say 'Today’s theme is Places. Think of a story you can tell someone about a specific place.'
    r.Say 'I will ask you to record the story, but first please say your name.'
    r.Record maxlength: 15, action: '/sender', method: 'get', transcribe: true, transcribeCallback: '/sender-transcription', playBeep: false
  end.text
end

get '/sender' do
  content_type 'text/xml'

  call_sid = params['CallSid']
  story = Story.find_by_call_sid(call_sid)
  sender_audio = params['RecordingUrl']
  story.update(sender_audio: sender_audio)

  Twilio::TwiML::Response.new do |r|
    r.Say 'Thank you. Now state the name of the place your story is about.'
    r.Record maxlength: 20, action: '/place', method: 'get', transcribe: true, transcribeCallback: '/place-transcription', playBeep: false
  end.text
end

get '/place' do
  content_type 'text/xml'

  call_sid = params['CallSid']
  story = Story.find_by_call_sid(call_sid)
  place_audio = params['RecordingUrl']
  story.update(place_audio: place_audio)

  Twilio::TwiML::Response.new do |r|
    r.Say 'Thank you. Now tell me your story. When finished, stop speaking or press star.'
    r.Record maxlength: 3600, action: '/story', method: 'get', playBeep: false, finishOnKey: '*'
  end.text
end

get '/story' do
  content_type 'text/xml'

  call_sid = params['CallSid']
  story = Story.find_by_call_sid(call_sid)
  story_audio = params['RecordingUrl']
  story.update(story_audio: story_audio)

  Twilio::TwiML::Response.new do |r|
    r.Say 'Thank you. Now please tell me the full name of the recipient.'
    r.Record maxlength: 20, action: '/recipient', method: 'get', transcribe: true, transcribeCallback: '/recipient-transcription', playBeep: false
  end.text
end

get '/recipient' do
  content_type 'text/xml'

  call_sid = params['CallSid']
  story = Story.find_by_call_sid(call_sid)
  recipient_audio = params['RecordingUrl']
  story.update(recipient_audio: recipient_audio)

  Twilio::TwiML::Response.new do |r|
    r.Say 'Thank you. I will send the story postcard on your behalf.'
    r.Hangup
  end.text
end

post '/sender-transcription' do
  content_type 'text/xml'
  puts params
end

post '/place-transcription' do
  content_type 'text/xml'
  puts params
end

post '/recipient-transcription' do
  content_type 'text/xml'
  puts params
end
