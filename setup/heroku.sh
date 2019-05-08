#!/usr/bin/env bash

# Install Heroku CLI
brew tap heroku/brew && brew install heroku

# installs plugin for heroku cli to manage multiple accounts
# https://github.com/heroku/heroku-accounts
heroku plugins:install https://github.com/heroku/heroku-accounts.git
