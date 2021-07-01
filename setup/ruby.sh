#!/usr/bin/env sh

RUBY_VERSION=`cat ~/.ruby-version`
echo "installing Ruby v$RUBY_VERSION..."

# Install ruby version specified in .ruby-version
CFLAGS="-Wno-error=implicit-function-declaration" rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION
rbenv rehash

# Install bundler
gem install bundler
