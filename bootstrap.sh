#!/bin/sh
set -eo pipefail

############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# as well as assorted other "setup" tasks
############################

# dotfiles directory
dir=~/dotfiles

# old dotfiles backup directory
olddir=~/dotfilesBackup

function log_section() {
  echo "$(tput setaf 0)$(tput setab 7)$(tput bold) $1 $(tput sgr 0)"
}

function log_step() {
  echo "$(tput setaf 6)- $1$(tput sgr 0)"
}

# create dotfilesBackup in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# list of files/folders to symlink in homedir
files=".aliases .bash_profile .bash_prompt .bashrc .exports .functions .gitconfig .gitignore .inputrc .gemrc .irbrc .pryrc .secrets .tool-versions .wgetrc"

# move any existing dotfiles in homedir to dotfilesBackup directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
echo "Moving any existing dotfiles from ~ to $olddir & Creating symlink to $files in home directory."
for file in $files; do
    mv ~/$file $olddir
    ln -s $dir/$file ~/$file
    echo "symlinking $dir/$file -> ~/$file"
done

# pre-emptive sudo signin
sudo echo ""

# optionally set computer name
echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "What would you like it to be?"
  read COMPUTER_NAME
  sudo scutil --set ComputerName $COMPUTER_NAME
  sudo scutil --set HostName $COMPUTER_NAME
  sudo scutil --set LocalHostName $COMPUTER_NAME
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
fi

# install Xcode Command Line Tools if not installed.
if xcode-select -p > /dev/null; then
  log "Xcode Command Line Tools already installed"
else
  xcode-select --install
fi

# check for Homebrew & install if necessary
if ! [ -x "$(command -v brew)" ]; then
  log "Homebrew not found, installing it"
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  UNAME_MACHINE="$(/usr/bin/uname -m)"
  if [[ "${UNAME_MACHINE}" == "arm64" ]]
  then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi

# setup homebrew and apps
echo "Installing binaries and apps with Homebrew"
brew bundle --verbose
echo "...done"

# check for any problems with homebrew
brew bundle check
brew doctor

# map vi so it opens the brew-installed vim
ln -s /usr/local/bin/vim /usr/local/bin/vi

# setup macOS
echo "Setting up macOS"
source ./setup/macos.sh
echo "...done"

# install fonts
echo "Installing fonts"
rsync --exclude ".DS_Store" -av --no-perms fonts/ ~/Library/Fonts/
echo "...done"

echo "Finalizing..."

# symlink diff-highlight into path
sudo ln -sf "$(brew --prefix)/share/git-core/contrib/diff-highlight/diff-highlight" /usr/bin/diff-highlight

# remap keyboard keys
# source ./setup/keymap.sh

# persist keymap after system reboot
sudo defaults write com.apple.loginwindow LoginHook ~/dotfiles/setup/keymap.sh

# attempt to add iOS Simulator to the dock
# for some reason this can't be in setup/macos.sh
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
killall Dock

echo "\n$(tput bold)Done. Note that some of these changes require a logout/restart to take effect.$(tput sgr 0)"
