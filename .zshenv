# set nano as default editor
export EDITOR='nano';

# set icdiff as default git diff tool
export DIFF=$HOME/dotfiles/code/icdiff

# Larger history (default is much smaller)
export HISTSIZE=1000000;
export HISTFILE=$HOME/.zsh_history;
export SAVEHIST=$HISTSIZE;

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# Don't clear the screen after quitting a manual page
export MANPAGER="less -X";

# Expiration time for the aws-vault GetSessionToken credentials (default is 1h)
export AWS_SESSION_TOKEN_TTL=12h

# x86_64 or arm64
export MACHINE_ARCHITECTURE="$(/usr/bin/uname -m)"

# Homebrew installs in different locations depending on architecture
if [[ "${MACHINE_ARCHITECTURE}" == "arm64" ]]
then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

# Prevent homebrew casks from throwing Gatekeeper message on opening
export HOMEBREW_CASK_OPTS=--no-quarantine

# Path adjustments
GITDIFF=$HOME/dotfiles/code/icdiff # make icdiff available for gdiff alias
CURL=/opt/homebrew/opt/curl/bin # make homebrew-install curl available
VITEPLUS=$HOME/.vite-plus/bin # Vite+ bin (https://viteplus.dev)

export PATH=$GITDIFF:$CURL:$VITEPLUS:$PATH
