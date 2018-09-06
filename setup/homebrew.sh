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

# Install GNU core utilities (those that come with macOS are outdated)
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install more recent versions of some macOS tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# Install wget with IRI support
brew install wget --enable-iri

# Install other useful binaries
binaries=(
  ack
  bash
  chromedriver
  coreutils
  dockutil
  git
  heroku-toolbelt
  id3lib
  maven
  memcached
  mongodb
  mysql
  nmap
  nvm
  openSSL
  optipng
  phantomjs
  postgresql@9.5
  python3
  rbenv
  readline
  redis
  rename
  ruby-build
  sqlite
  subversion
  trash
  tree
  watch
  watchman
  wget
  yarn
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
  android-studio
  appcleaner
  arduino
  docker
  dropbox
  evernote
  filezilla
  firefox
  flux
  google-chrome
  google-chrome-canary
  insomnia
  iterm2
  java
  keepingyouawake
  licecap
  livereload
  macdown
  rdm
  robomongo
  selfcontrol
  sketch
  sketchup
  skype
  slack
  spotify
  sqlitestudio
  sublime-text3
  virtualbox
  viscosity
  xquartz
)

installcask ${apps[@]}

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
