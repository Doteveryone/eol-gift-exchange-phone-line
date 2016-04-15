# Gift exchange phone interface

This is a test project designed to try out some of our assumptions about reciprocal gift giving among people in geographic proximity.

## Tech specs

The project runs on Ruby and Sinatra, and makes use of Twilio for call handling. The call script is written using Twilio’s markup language (TwiML).

## Installation

Clone the repository and run `bundle install` from the project’s root.

To try out the call you will need to set up a Twilio account and point it to the app.

## Inspecting the records on Heroku

Run `heroku run console` to load the interactive Ruby environment.
