#!/usr/bin/env bash

NODE_VERSION=`cat ~/.nvmrc`
echo "installing NodeJS $NODE_VERSION..."

# Install node version specified in .nvmrc
nvm install $NODE_VERSION
# Set default node version for shell
nvm use $NODE_VERSION
nvm alias default node

# Development
# npm install -g iectrl # IE VMs
npm install serverless -g
