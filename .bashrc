# path settings
COREUTILS=$(brew --prefix coreutils)/libexec/gnubin
GIT=/usr/local/git/bin
HOMEBREW=/usr/local/bin:/usr/local/lib:/usr/local/sbin
HEROKU=/usr/local/heroku/bin
RBENV=$HOME/.rbenv/bin
RBENV_SHIMS=$HOME/.rbenv/shims
NVM_DIR=~/.nvm
DOCKER=~/dotfiles/code/docker
DIFF=~/dotfiles/code/icdiff

export PATH=$PATH:$GIT:$HOMEBREW:$HEROKU:$RBENV:$RBENV_SHIMS:$NVM_DIR:$DOCKER:$DIFF:$COREUTILS

# loads dotfiles into shell
# ~/.extra used for settings I don’t want to commit
for file in ~/.{bash_prompt,aliases,functions,exports,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

# init rbenv for ruby
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# init nvm for node
source $(brew --prefix nvm)/nvm.sh

# init z (https://github.com/rupa/z)
source ~/dotfiles/code/z/z.sh

# tab completion for Git
source ~/dotfiles/code/git-completion.bash

# tab completion for homebrew
source ~/dotfiles/code/homebrew-completion.sh

# tab completion for gulp
source ~/dotfiles/code/gulp-completion.sh

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall
