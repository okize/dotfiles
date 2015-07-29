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

echo "installing binaries..."

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
binaries=(
  ack
  elasticsearch
  git
  git-cal
  graphicsmagick
  hub
  licecap
  memcached
  mongodb
  mysql
  nvm
  optipng
  phantomjs
  postgresql
  python3
  rbenv
  redis
  rename
  Rserve
  ruby-build
  slack
  sqlite
  trash
  tree
  webkit2png
)

brew install ${binaries[@]}

brew tap phinze/homebrew-cask
brew tap caskroom/versions
brew install brew-cask

function installcask() {
  brew cask install "${@}" 2> /dev/null
}

echo "installing applications..."

# Install native applications
apps=(
  adium
  alfred
  appcleaner
  dropbox
  firefox
  flux
  evernote
  google-chrome
  google-chrome-canary
  iterm2
  mou
  opera
  opera-mobile-emulator
  rdm
  robomongo
  selfcontrol
  sublime-text3
  xquartz
  virtualbox
)

installcask ${apps[@]}

# links apps to Alfred since they are not install in /Applications
brew cask alfred link

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
