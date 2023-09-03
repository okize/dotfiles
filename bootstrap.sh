#!/bin/sh

############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# as well as assorted other "setup" tasks
############################

# order of operations
main() {
  symlink_dotfiles
  set_computer_name
  install_xcode_cli
  install_homebrew
  install_brewfile_packages
  install_asdf
  setup_macos
}

# dotfiles directory
dir=~/dotfiles

# old dotfiles backup directory
olddir=~/dotfilesBackup

# pinned asdf version
ASDF_VERSION=0.12.0

# pre-emptive sudo signin
sudo echo ""

function log_section() {
  echo "$(tput setaf 0)$(tput setab 7)$(tput bold) $1 $(tput sgr 0)"
}

function log_step() {
  echo "$(tput setaf 6)- $1$(tput sgr 0)"
}

function symlink_dotfiles() {
  # create dotfilesBackup in homedir
  echo "Creating $olddir for backup of any existing dotfiles in ~"
  mkdir -p $olddir

  # change to the dotfiles directory
  echo "Changing to the $dir directory"
  cd $dir

  # list of files/folders to symlink in homedir
  files=".aliases .bash_profile .bash_prompt .bashrc .exports .functions .gitconfig .gitignore .inputrc .gemrc .irbrc .pryrc .secrets .tool-versions .wgetrc"

  # move any existing dotfiles in homedir to dotfilesBackup directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
  echo "Moving any existing dotfiles from ~ to $olddir & Creating symlink to $files in home directory."
  for file in $files; do
      mv ~/$file $olddir
      ln -s $dir/$file ~/$file
      echo "symlinking $dir/$file -> ~/$file"
  done

  # reload shell session
  source ~/.bashrc;
}

# optionally set computer name
function set_computer_name() {
  echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
  read -r response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "What would you like it to be?"
    read COMPUTER_NAME
    sudo scutil --set ComputerName $COMPUTER_NAME
    sudo scutil --set HostName $COMPUTER_NAME
    sudo scutil --set LocalHostName $COMPUTER_NAME
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
  else
    echo "Skipping computer rename"
  fi
}

# install Xcode Command Line Tools if not installed
install_xcode_cli() {
  if xcode-select -p > /dev/null; then
    echo "XCode CLI tools already installed"
  else
    xcode-select --install
  fi
}

# check for Homebrew & install if necessary
install_homebrew() {
  if ! [ -x "$(command -v brew)" ]; then
    echo "Homebrew not found, installing it"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# install brews & casks from Brewfile
install_brewfile_packages() {
  echo "Installing binaries and apps with Homebrew"
  brew bundle --verbose

  # map vi so it opens the brew-installed vim
  ln -s $HOMEBREW_PREFIX/bin/vim $HOMEBREW_PREFIX/bin/vi

  # check for any problems with homebrew
  brew bundle check
  brew doctor
}

# if not already installed, install a pinned version of asdf via git into ${HOME}/.asdf
# then preinstall some frequently used plugins
install_asdf() {
  if ! [ -x "$(command -v asdf)" ]; then
    echo "asdf not found, installing it"
    if [ ! -d ~/.asdf ]; then
      git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v$ASDF_VERSION
    fi

    # Enable asdf for use by this script
    . $HOME/.asdf/asdf.sh
  fi

  echo "asdf version $(asdf --version) is installed"

  if ! asdf plugin-list | grep -q yarn; then
    echo "Adding yarn plugin to asdf"
    asdf plugin-add yarn
  fi
  asdf plugin-update yarn

  if ! asdf plugin-list | grep -q nodejs; then
    echo "Adding nodejs plugin to asdf"
    asdf plugin-add nodejs
  fi
  asdf plugin-update nodejs

  # install whatever is set in ~/.tool-versions
  asdf install
}

# install brews & casks from Brewfile
install_brewfile_packages() {
  echo "Installing binaries and apps with Homebrew"
  brew bundle --verbose

  # map vi so it opens the brew-installed vim
  ln -s /usr/local/bin/vim /usr/local/bin/vi

  # check for any problems with homebrew
  brew bundle check
  brew doctor
}

setup_macos() {
  echo "Setting up macOS"
  source ./setup/macos.sh

  echo "Installing fonts"
  rsync --exclude ".DS_Store" -av --no-perms fonts/ ~/Library/Fonts/

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
}

main "$@"

echo "\n$(tput bold)Done. Note that some of these changes require a logout/restart to take effect.$(tput sgr 0)"
