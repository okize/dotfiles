#!/usr/bin/env bash

# Install most recent stable node & set default node version for shell
nvm install stable
nvm use stable
nvm alias default node

# Development
npm install -g express-generator
npm install -g grunt-cli
npm install -g gulp
npm install -g iectrl
npm install -g node-inspector
npm install -g nodemon

# Tools
npm install -g browser-repl
npm install -g stylestats

# My modules
npm install -g iconr
npm install -g npm-popular
npm install -g selector-detector
npm install -g trendie
