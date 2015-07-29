#!/usr/bin/env bash

# Check for Homebrew & install if necessary
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# Install wget with IRI support
brew install wget --enable-iri

# Install other useful binaries
brew install ack
brew install elasticsearch
brew install git
brew install git-cal
brew install graphicsmagick
brew install hub
brew install memcached
brew install mongodb
brew install mysql
brew install nvm
brew install optipng
brew install phantomjs
brew install postgresql
brew install python3
brew install rbenv
brew install redis
brew install rename
brew install Rserve
brew install ruby-build
brew install sqlite
brew install trash
brew install tree
brew install webkit2png
brew install wget

# Install native apps
brew tap phinze/homebrew-cask
brew tap caskroom/versions
brew install brew-cask

function installcask() {
  brew cask install "${@}" 2> /dev/null
}

installcask adium
installcask appcleaner
installcask dropbox
installcask firefox
installcask flux
installcask evernote
installcask google-chrome
installcask google-chrome-canary
installcask iterm2
installcask mou
installcask opera
installcask opera-mobile-emulator
installcask rdm
installcask robomongo
installcask selfcontrol
installcask sublime-text3
installcask xquartz
installcask virtualbox

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
