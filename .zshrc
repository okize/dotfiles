# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# loads dotfiles into shell
# note: .secrets is used for settings I don't want to commit
for file in ~/.{aliases,functions,secrets}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Enable zsh features:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Extended globbing for advanced pattern matching
setopt autocd
setopt extendedglob
setopt HIST_IGNORE_SPACE # prevents commands from being saved to your command history if they begin with a leading space
setopt HIST_REDUCE_BLANKS # removes blank lines from history
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_FIND_NO_DUPS #ignore duplicates when searching
setopt HIST_IGNORE_DUPS # do not store duplications
setopt EXTENDED_HISTORY # extend size of stored history
setopt SHARE_HISTORY # share history across multiple zsh sessions
setopt APPEND_HISTORY # append to history
setopt HIST_VERIFY # show expanded history command before executing
setopt INC_APPEND_HISTORY # adds commands to history as they are typed, not at shell exit
setopt NO_NOMATCH # don't error on unmatched globs
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell
setopt NO_CASE_GLOB # make globbing case insensitive
setopt CORRECT # enable correction
setopt CORRECT_ALL

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

# powerlevel10k prompt theme (https://github.com/romkatv/powerlevel10k)
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# zsh-autosuggestions (suggest commands as you type, accept with right arrow)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting (must be sourced last)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# keybindings (replaces .inputrc)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[3;3~' kill-word

# worktrunk shell integration
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/morganwigmanich/.lmstudio/bin"
# End of LM Studio CLI section

