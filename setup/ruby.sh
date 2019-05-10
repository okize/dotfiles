#!/usr/bin/env bash

RUBY_VERSION=`cat ~/.ruby-version`
echo "installing Ruby v$RUBY_VERSION..."

# Install ruby version specified in .ruby-version
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION
rbenv rehash

# Install bundler
gem install bundler
