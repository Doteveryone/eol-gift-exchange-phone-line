# Gift exchange phone interface

This is a test project designed to try out some of our assumptions about reciprocal gift giving among people in geographic proximity.

## Tech specs

The project runs on Ruby and Sinatra, and makes use of Twilio for call handling. The call script is written using Twilio’s markup language (TwiML).

## Installation

Clone the repository and run `bundle install` from the project’s root.

### Twilio

To try out the call you will need to set up a Twilio account and point it to the app.

### Heroku

On Heroku you will have to set up the following environment variables to connect to the database: DATABASE, USER, HOST, PORT.

### Postmark

Email notifications require a Postmark account. Add POSTMARK_KEY, NOTIFICATION_SOURCE and NOTIFICATION_RECIPIENT environment variables to Heroku.

## Inspecting the records on Heroku

Run `heroku run console` to load the interactive Ruby environment.
