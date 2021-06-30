#!/usr/bin/env sh

NODE_VERSION=`cat ~/.nvmrc`
echo "installing NodeJS $NODE_VERSION..."

# Install node version specified in .nvmrc
nvm install $NODE_VERSION

# Set default node version for shell
nvm use $NODE_VERSION
nvm alias default node

# Development
npm install create-react-app -g
npm install expo-cli -g
