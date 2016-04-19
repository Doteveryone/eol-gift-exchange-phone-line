require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'twilio-ruby'
require 'postmark'

Dotenv.load

set :logging, true

postmark = Postmark::ApiClient.new(ENV['POSTMARK_KEY'])

class Story < ActiveRecord::Base
end

get '/' do
  content_type 'text/xml'

  Story.create(call_sid: params['CallSid'])

  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, you are using a service which lets you send audio postcards, made by the Products and Services team.'
    r.Say 'Today’s theme is Places. Think of a story you can tell someone about a specific place.'
    r.Say 'I will ask you a few questions to fill out the postcard. I will ask your name, the recipient\'s name, the name of the place you can tell a story about, and finally, the story itself.'
    r.Say 'I will play some muzak while you have a think about what to say. When you\'re ready press any key and I will begin asking the questions.'
    r.Redirect '/thinking', method: 'get'
  end.text
end

get '/thinking' do
  content_type 'text/xml'

  Twilio::TwiML::Response.new do |r|
    r.Gather numdigits: '1', action: '/record', method: 'get', timeout: 3600, finishOnKey: '' do |g|
      g.Play 'http://prototyping-temp-files.s3.amazonaws.com/muzak.mp3'
    end
  end.text
end

get '/record' do
  content_type 'text/xml'

  # no new content, so we don’t have to fetch
  # anything from the database

  Twilio::TwiML::Response.new do |r|
    r.Say 'I will ask about your name, the recipient\'s name, the name of the place, and finally about your story.'
    r.Say 'Please say your name.'
    r.Record maxlength: 15, action: '/sender', method: 'get', playBeep: false
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
    r.Record maxlength: 20, action: '/place', method: 'get', playBeep: false
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
    r.Record maxlength: 20, action: '/recipient', method: 'get', playBeep: false
  end.text
end

get '/recipient' do
  content_type 'text/xml'

  call_sid = params['CallSid']
  story = Story.find_by_call_sid(call_sid)
  recipient_audio = params['RecordingUrl']
  story.update(recipient_audio: recipient_audio)

  postmark.deliver(
    from: ENV['NOTIFICATION_SOURCE'],
    to: ENV['NOTIFICATION_RECIPIENT'],
    subject: '[Gift Exchange] New story was created',
    html_body: "Sender: #{story.sender_audio}<br>Recipient: #{story.recipient_audio}<br>Place: #{story.place_audio}<br>Story: #{story.story_audio}",
    track_opens: true)

  Twilio::TwiML::Response.new do |r|
    r.Say 'Thank you. I will send the story postcard on your behalf.'
    r.Hangup
  end.text
end
