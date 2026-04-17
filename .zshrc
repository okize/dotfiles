# loads dotfiles into shell
# note: .secrets is used for settings I don't want to commit
for file in ~/.{zsh_prompt,aliases,functions,secrets}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Enable zsh features:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Extended globbing for advanced pattern matching
setopt autocd
setopt extendedglob
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt NO_NOMATCH # don't error on unmatched globs

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty);

# initialize homebrew
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# TODO is there a better way to do this?
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# initialize zoxide (smarter cd, replaces z)
eval "$(zoxide init zsh)"

# initialize fzf keybindings and completion
# Ctrl+R: fuzzy history search, Ctrl+T: fuzzy file finder, Alt+C: fuzzy cd
source <(fzf --zsh)

# uncomment to make `vp env use` work
# . "$HOME/.vite-plus/env"

# zsh completion system (only regenerate dump once per day)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# highlight current completion selection
zstyle ':completion:*' menu select

# colorize completion listings
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [ -e "$HOME/.ssh/config" ]; then
  _ssh_hosts=($(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n'))
  zstyle ':completion:*:ssh:*' hosts $_ssh_hosts
  zstyle ':completion:*:scp:*' hosts $_ssh_hosts
  zstyle ':completion:*:sftp:*' hosts $_ssh_hosts
fi

# keybindings (replaces .inputrc)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[3;3~' kill-word
