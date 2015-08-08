#!/usr/bin/env bash

# Create ~/Projects dir
mkdir ~/Projects

# Symlink Sublime Text to subl in terminal
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime

# Remove package dirs if they exist
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Install\ Packages

# Symlink package dirs to dotfiles repo
ln -s ~/dotfiles/sublime/Installed\ Packages ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
ln -s ~/dotfiles/sublime/Packages ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
