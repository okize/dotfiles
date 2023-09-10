# loads dotfiles into shell
# note: .secrets is used for settings I don't want to commit
for file in ~/.{bash_prompt,aliases,functions,exports,secrets}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# initialize homebrew
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# initialize z (https://github.com/rupa/z)
source ~/dotfiles/code/z/z.sh

# initialize asdf
. "$HOME/.asdf/asdf.sh"

# tab completion for asdf
. "$HOME/.asdf/completions/asdf.bash"

# tab completion for Git
source ~/dotfiles/code/git-completion.bash

# tab completion for NPM
source ~/dotfiles/code/npm-completion.sh

# tab completion for Homebrew
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall
