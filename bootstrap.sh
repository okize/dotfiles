#!/usr/bin/env sh

############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# as well as assorted other "setup" tasks
############################

# dotfiles directory
dir=~/dotfiles

# old dotfiles backup directory
olddir=~/dotfilesBackup

# create dotfilesBackup in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# list of files/folders to symlink in homedir
files=".aliases .bash_profile .bash_prompt .bashrc .exports .functions .gitconfig .gitignore .inputrc .gemrc .irbrc .nvmrc .pryrc .rspec .ruby-version .secrets .vimrc .wgetrc"

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

# Check for Homebrew & install if necessary
if [ ! -n "$(command -v brew)" ]
then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Accept Xcode license
sudo xcodebuild -license accept

# Setup homebrew and apps
echo "Installing binaries and apps with Homebrew"
brew bundle --verbose
echo "...done"

# Check for any problems with homebrew
brew bundle check
brew doctor

# Map vi so it opens the brew-installed vim
ln -s /usr/local/bin/vim /usr/local/bin/vi

# Setup Node environment
echo "Installing node and global modules"
source ./setup/node.sh
echo "...done"

# Setup Ruby environment
echo "Setting up Ruby, Bundler & Rake"
source ./setup/ruby.sh
echo "...done"

# Setup Heroku
echo "Setting up Heroku"
source ./setup/heroku.sh
echo "...done"

# Setup macOS
echo "Setting up macOS"
source ./setup/macos.sh
echo "...done"

# install fonts
echo "Installing fonts"
rsync --exclude ".DS_Store" -av --no-perms fonts/ ~/Library/Fonts/
echo "...done"

echo "Finalizing..."
# install VS Code settings sync extension
code --install-extension Shan.code-settings-sync

# symlink diff-highlight into path
sudo ln -sf "$(brew --prefix)/share/git-core/contrib/diff-highlight/diff-highlight" /usr/bin/diff-highlight

# remap keyboard keys
source ./setup/keymap.sh

# persist keymap after system reboot
sudo defaults write com.apple.loginwindow LoginHook ~/dotfiles/setup/keymap.sh

# Attempt to add iOS Simulator to the dock
# for some reason this can't be in setup/macos.sh
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
killall Dock

echo "\n$(tput bold)Done. Note that some of these changes require a logout/restart to take effect.$(tput sgr 0)"
echo "To sync VS Code settings, open Code and paste Github Personal Access Token & Gist ID
