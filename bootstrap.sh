#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

# dotfiles directory
dir=~/dotfiles

# old dotfiles backup directory
olddir=~/dotfilesBackup

# list of files/folders to symlink in homedir
files=".aliases .bash_profile .bash_prompt .bashrc .eslintrc .exports .extra .functions .gitconfig .gitignore .inputrc .gemrc .gitk .irbrc .pryrc .rspec .vimrc .wgetrc"

# create dotfilesBackup in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfilesBackup directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
echo "Moving any existing dotfiles from ~ to $olddir & Creating symlink to $files in home directory."
for file in $files; do
    mv ~/$file $olddir
    ln -s $dir/$file ~/$file
    echo "symlinking $dir/$file -> ~/$file"
done

# install fonts
echo "Installing fonts"
rsync --exclude ".DS_Store" -av --no-perms fonts/ ~/Library/Fonts/
echo "...done"

# Setup homebrew and apps
echo "Installing binaries and apps with Homebrew"
source ./setup/homebrew.sh
echo "...done"

# Setup Node environment
echo "Installing node and global modules"
source ./setup/node.sh
echo "...done"

# Setup Ruby environment
echo "Setting up Ruby, Bundler & Rake"
source ./setup/ruby.sh
echo "...done"

# Setup Sublime Text environment
echo "Setting up Sublime Text"
source ./setup/sublime.sh
echo "...done"

# Setup OS X
echo "Setting up OS X"
source ./setup/osx.sh
echo "...done"
