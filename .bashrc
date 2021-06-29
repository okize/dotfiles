# path settings
COREUTILS=/usr/local/opt/coreutils/libexec/gnubin
FINDUTILS=/usr/local/opt/findutils/libexec/gnubins
SED=/usr/local/opt/gnu-sed/libexec/gnubin
DIFF=$HOME/dotfiles/code/icdiff
GIT=/usr/local/git/bin
AWSEBCLI=$HOME/.local/bin
HEROKU=/usr/local/heroku/bin
HOMEBREW=/usr/local/bin:/usr/local/lib:/usr/local/sbin
MYSQL=/usr/local/opt/mysql@5.6/bin
NVM_DIR=$HOME/.nvm
POSTGRES=/usr/local/opt/postgresql@9.5/bin
PYENV_ROOT=$HOME/.pyenv
PYTHON=$HOME/Library/Python/2.7/bin
RBENV=$HOME/.rbenv/bin
RBENV_SHIMS=$HOME/.rbenv/shims
YARN=$HOME/.yarn/bin
ANDROID_HOME=$HOME/Library/Android/sdk
ANDROID_TOOLS=$ANDROID_HOME/tools
ANDROID_TOOLS_BIN_STUBS=$ANDROID_TOOLS/bin
ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools
OPEN_SSL=/usr/local/opt/openssl/bin
LIBRARY_PATH=/usr/local/opt/openssl/lib/

export PATH=$PATH:$COREUTILS:$FINDUTILS:$SED:$DIFF:$GIT:$HEROKU:$HOMEBREW:$NVM_DIR:$POSTGRES:$MYSQL:$AWSEBCLI:$PYTHON:$PYENV_ROOT:$RBENV:$RBENV_SHIMS:$YARN:$ANDROID_HOME:$ANDROID_TOOLS:$ANDROID_TOOLS_BIN_STUBS:$ANDROID_PLATFORM_TOOLS:$OPEN_SSL:$LIBRARY_PATH

# loads dotfiles into shell
# ~/.extra used for settings I don't want to commit
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

# # Setup Compiler paths for readline and openssl
# # discoverable via `brew --prefix openssl` z& `brew --prefix readline`
# # see: https://github.com/rbenv/ruby-build/issues/1409
# OPENSSL_PATH="/usr/local/opt/openssl@1.1"
# READLINE_PATH="/usr/local/opt/readline"

# # for compilers to find openssl@1.1
# export LDFLAGS="-L$OPENSSL_PATH/lib"
# export CPPFLAGS="--I$OPENSSL_PATH/include"

# # Use the OpenSSL from Homebrew instead of ruby-build
# # Note: the Homebrew version gets updated, the ruby-build version doesn't
# export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$OPENSSL_PATH"
# export PKG_CONFIG_PATH="$READLINE_PATH/lib/pkgconfig:$OPENSSL_PATH/lib/pkgconfig"

# # place openssl@1.1 at the beginning of PATH (preempt system libs)
# export PATH=$OPENSSL_PATH/bin:$PATH

# init rbenv for ruby
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# init pyenv for python
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
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
