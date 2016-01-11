#!/usr/bin/env bash
# http://sticksnglue.com/wordpress/a-future-without-boot2docker-featuring-docker-machine/

brew install docker-machine

# setup a virtual machine for docker to use
docker-machine create --driver virtualbox dev

#set up docker client
eval "$(docker-machine env dev)"

#
brew tap codeclimate/formulae

#
brew install codeclimate
