#!/usr/bin/env bash

# install latest Ruby
rbenv install 2.2.0
rbenv global 2.2.0
rbenv rehash

# install some gems
gem install bundler
gem install rake
