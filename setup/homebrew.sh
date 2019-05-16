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

# Alternate versions of casks (eg. Chrome Canary)
brew tap homebrew/cask-versions

echo "installing binaries..."

# Install GNU core utilities (those that come with macOS are outdated)
brew install coreutils

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

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
  gnu-sed
  gnupg
  grep
  id3lib
  memcached
  nmap
  nvm
  openssh
  openSSL
  postgresql@9.5
  pyenv
  rbenv
  readline
  redis
  rename
  ruby-build
  screen
  sqlite
  trash
  tree
  vim
  watch
  watchman
  wget
  yarn
  youtube-dl
)

brew install ${binaries[@]}

function installcask() {
  brew cask install "${@}"
}

echo "installing applications..."

# download and install native binaries
apps=(
  android-studio
  appcleaner
  balenaetcher
  chromedriver
  cyberduck
  docker
  dropbox
  evernote
  firefox
  google-chrome
  insomnia
  iterm2
  karabiner-elements
  keepingyouawake
  licecap
  macdown
  selfcontrol
  sketch
  slack
  spotify
  viscosity
  xquartz
  zoomus
)

installcask ${apps[@]}

# Remove outdated versions from the cellar
brew cleanup

# Check for any problems
brew doctor
