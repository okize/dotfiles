# path settings
COREUTILS=$(brew --prefix coreutils)/libexec/gnubin
DIFF=$HOME/dotfiles/code/icdiff
GIT=/usr/local/git/bin
HEROKU=/usr/local/heroku/bin
HOMEBREW=/usr/local/bin:/usr/local/lib:/usr/local/sbin
NVM_DIR=$HOME/.nvm
POSTGRES=/usr/local/opt/postgresql@9.5/bin
PYTHON=$HOME/Library/Python/2.7/bin
RBENV=$HOME/.rbenv/bin
RBENV_SHIMS=$HOME/.rbenv/shims
YARN=$HOME/.yarn/bin
ANDROID_HOME=$HOME/Library/Android/sdk
ANDROID_TOOLS=$ANDROID_HOME/tools
ANDROID_TOOLS_BIN_STUBS=$ANDROID_TOOLS/bin
ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools

export PATH=$PATH:$COREUTILS:$DIFF:$GIT:$HEROKU:$HOMEBREW:$NVM_DIR:$POSTGRES:$PYTHON:$RBENV:$RBENV_SHIMS:$YARN:$ANDROID_HOME:$ANDROID_TOOLS:$ANDROID_TOOLS_BIN_STUBS:$ANDROID_PLATFORM_TOOLS

# loads dotfiles into shell
# ~/.extra used for settings I don’t want to commit
for file in ~/.{bash_prompt,aliases,functions,exports,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# init rbenv for ruby
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# init nvm for node
# moved to .functions for lazy-loading

# init z (https://github.com/rupa/z)
source ~/dotfiles/code/z/z.sh

# tab completion for Git
source ~/dotfiles/code/git-completion.bash

# tab completion for homebrew
source ~/dotfiles/code/homebrew-completion.sh

# tab completion for NPM
source ~/dotfiles/code/npm-completion.sh

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall
