#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfilesBackup           # old dotfiles backup directory
files=".aliases .bash_profile .bash_prompt .bashrc .exports .extra .functions .gitconfig .gitignore .inputrc .gemrc .gitk .irbrc .pryrc .rspec .wgetrc"    # list of files/folders to symlink in homedir

##########

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
source homebrew.sh

# Setup Node environment
source node.sh

# Setup Ruby environment
source ruby.sh

# Setup OS X
source osx.sh
