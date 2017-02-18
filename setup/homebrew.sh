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
  dockutil
  flow
  git
  graphicsmagick
  heroku-toolbelt
  hub
  id3lib
  imagemagick
  memcached
  mongodb
  mysql
  nmap
  nvm
  openSSL
  optipng
  phantomjs
  postgresql95
  python3
  rbenv
  redis
  rename
  Rserve
  ruby-build
  sqlite
  trash
  tree
  watch
  watchman
  webkit2png
  youtube-dl
)

brew install ${binaries[@]}

# installs plugin for heroku cli to manage multiple accounts
# https://github.com/heroku/heroku-accounts
heroku plugins:install https://github.com/heroku/heroku-accounts.git

function installcask() {
  brew cask install --appdir="/Applications" "${@}" 2> /dev/null
}

echo "installing applications..."

# download and install native binaries
apps=(
  alfred
  appcleaner
  arduino
  docker
  dropbox
  evernote
  firefox
  flux
  google-chrome
  google-chrome-canary
  hyper
  iterm2
  java
  keepingyouawake
  licecap
  livereload
  mou
  opera
  rdm
  robomongo
  screenhero
  selfcontrol
  skype
  slack
  sqlitestudio
  sublime-text3
  virtualbox
  xquartz
)

installcask ${apps[@]}

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
