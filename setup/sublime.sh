#!/usr/bin/env bash

# Create ~/Projects dir
mkdir ~/Projects

# Symlink Sublime Text to subl in terminal
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime

# Remove Sublime config dir if it exists
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

# Setup Sublime Text user settings
git clone https://github.com/okize/sublime-text-settings.git -b sublime-text-3 --single-branch ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

# Setup Packages
wget -P ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages https://packagecontrol.io/Package%20Control.sublime-package
