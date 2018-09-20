#!/usr/bin/env bash

# Check for Homebrew & install if necessary
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Use the latest Homebrew
brew update

# Upgrade any already-installed packages
brew upgrade

echo "installing binaries..."

# Install GNU core utilities (those that come with macOS are outdated)
brew install coreutils

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install wget with IRI support
brew install wget --enable-iri

# Install more recent versions of Vim
brew install vim --with-override-system-vi

# Install Bash 4
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# Install other useful binaries
binaries=(
  ack
  bash
  coreutils
  dockutil
  git
  git-lfs
  ghostscript
  gnupg
  grep
  heroku-toolbelt
  id3lib
  memcached
  mongodb
  mysql
  nmap
  nvm
  openssh
  openSSL
  optipng
  postgresql@9.5
  python3
  rbenv
  readline
  redis
  rename
  ruby-build
  screen
  sqlite
  subversion
  trash
  tree
  watch
  watchman
  yarn
  youtube-dl
)

brew install ${binaries[@]}

# installs plugin for heroku cli to manage multiple accounts
# https://github.com/heroku/heroku-accounts
heroku plugins:install https://github.com/heroku/heroku-accounts.git

function installcask() {
  brew cask install "${@}"
}

echo "installing applications..."

# download and install native binaries
apps=(
  android-studio
  appcleaner
  chromedriver
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
  keepingyouawake
  licecap
  macdown
  selfcontrol
  sketch
  skype
  slack
  spotify
  sublime-text
  virtualbox
  viscosity
  xquartz
)

installcask ${apps[@]}

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
