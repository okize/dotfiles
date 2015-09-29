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
  git-cal
  graphicsmagick
  heroku-toolbelt
  hub
  imagemagick
  memcached
  mongodb
  mysql
  nvm
  optipng
  phantomjs
  postgresql93
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
  watchman
  webkit2png
)

brew install ${binaries[@]}

brew tap phinze/homebrew-cask
brew tap caskroom/versions
brew install brew-cask

function installcask() {
  brew cask install --appdir="/Applications" "${@}" 2> /dev/null
}

echo "installing applications..."

# Install native applications
apps=(
  adium
  alfred
  appcleaner
  dropbox
  evernote
  firefox
  flux
  google-chrome
  google-chrome-canary
  iterm2
  keepingyouawake
  licecap
  livereload
  mou
  opera
  opera-mobile-emulator
  rdm
  robomongo
  selfcontrol
  slack
  sublime-text3
  virtualbox
  xquartz
)

installcask ${apps[@]}

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
