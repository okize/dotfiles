# path settings
GIT=/usr/local/git/bin
HOMEBREW=/usr/local/bin:/usr/local/lib:/usr/local/sbin
HEROKU=/usr/local/heroku/bin
RBENV=$HOME/.rbenv/bin
RBENV_SHIMS=$HOME/.rbenv/shims
NVM_DIR=~/.nvm
DOCKER=~/dotfiles/code/docker
DIFF=~/dotfiles/code/icdiff
COREUTILS=$(brew --prefix coreutils)/libexec/gnubin
export PATH=$GIT:$HOMEBREW:$HEROKU:$RBENV:$RBENV_SHIMS:$NVM_DIR:$DOCKER:$DIFF:$COREUTILS:$PATH

# loads dotfiles into shell
# ~/.extra used for settings I don’t want to commit
for file in ~/.{bash_prompt,aliases,functions,exports,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

# init rbenv
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# init nvm for node
source $(brew --prefix nvm)/nvm.sh

# init z (https://github.com/rupa/z)
. ~/dotfiles/code/z/z.sh

# tab completion for Git
. ~/dotfiles/code/git-completion.bash

# tab completion for homebrew
. ~/dotfiles/code/homebrew-completion.sh

# tab completion for gulp
. ~/dotfiles/code/gulp-completion.sh

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# if possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# sets gitconfig email based on computer in use (work v. home)
if [ ${HOME} == "/Users/mwigmanich" ]; then
  git config --global user.email okize123@gmail.com
else
  git config --global user.email mwigmanich@patientslikeme.com
fi
