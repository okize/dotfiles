#!/usr/bin/env bash

# Install most recent stable node & set default node version for shell
nvm install stable
nvm use stable
nvm alias default node

# Development
npm install -g bower
npm install -g browserify
npm install -g coffee-script
npm install -g coffeelint
npm install -g ember-cli
npm install -g eslint_d
npm install -g grunt-cli
npm install -g gulp
npm install -g mocha
npm install -g nodemon
npm install -g webpack

# Tools
npm install -g browser-repl
npm install -g stylestats

# My modules
npm install -g iconr
npm install -g npm-popular
npm install -g selector-detector
npm install -g trendie
