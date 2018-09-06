#!/usr/bin/env bash

# install latest Ruby
rbenv install 2.5.1
rbenv global 2.5.1
rbenv rehash

# install some gems
gem install bundler
