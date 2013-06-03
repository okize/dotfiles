# path settings
HOMEBREW=/usr/local/bin:/usr/local/sbin
NODE=/usr/local/share/npm/bin:/usr/local/share/npm/lib/node_modules
GIT=/usr/local/git/bin
# RBENV=~/.rbenv/shims:/usr/bin/gcc-4.2
RVM=$PATH:$HOME/.rvm/bin
GEM=$(cd $(which gem)/..; pwd)
#PY="/Library/Frameworks/Python.framework/Versions/2.7/bin"
export PATH=$HOMEBREW:$NODE:$GIT:$RVM:$GEM:$PATH

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra used for settings I don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

# logs defaults write commands
PROMPT_COMMAND='echo "$(history 1 | grep "defaults")" | sed '/^$/d' >> ~/dotfiles/.defaults'

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# tab completion for git
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# tab completion for Grunt commands
which grunt > /dev/null && eval "$(grunt --completion=bash)"

# tab completion for 'defaults read|write NSGlobalDomain'
complete -W "NSGlobalDomain" defaults

# `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# If possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# initialize z
# https://github.com/rupa/z
. ~/dotfiles/code/z/z.sh


# init rbenv
# eval "$(rbenv init -)"

# PLM-specific
export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000
export ARCHFLAGS="-arch x86_64"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
