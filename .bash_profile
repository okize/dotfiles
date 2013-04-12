# path settings
HOMEBREW=/usr/local/bin:/usr/local/sbin
NODE=/usr/local/lib/node:/usr/local/lib/node_modules
GIT=/usr/local/git/bin
RBENV=~/.rbenv/shims:/usr/bin/gcc-4.2
GEM=$(cd $(which gem)/..; pwd)
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH=$HOMEBREW:$NODE:$GIT:$RBENV:$GEM:$PATH

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra used for settings I don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

# Keep Track of Defaults Write Commands
PROMPT_COMMAND='echo "$(history 1 | grep "defaults")" | sed '/^$/d' >> ~/dotfiles/.defaults'

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# initialize z
# https://github.com/rupa/z
. ~/code/z/z.sh

# init rbenv
eval "$(rbenv init -)"
# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}
