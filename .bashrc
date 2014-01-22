# path settings
HOMEBREW=/usr/local/bin:/usr/local/sbin
NODE=/usr/local/share/npm/bin:/usr/local/share/npm/lib/node_modules
GIT=/usr/local/git/bin
RBENV=/usr/local/var/rbenv
GEM=$(cd $(which gem)/..; pwd)
HEROKU=/usr/local/heroku/bin
GO=/usr/local/go/bin
export PATH=$HOMEBREW:$NODE:$GIT:$RBENV:$GEM:$HEROKU:$GO:$PATH

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra used for settings I don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
  [ -r "$file" ] && source "$file"
done
unset file

# logs defaults write commands
PROMPT_COMMAND='echo "$(history 1 | grep "defaults")" | sed '/^$/d' >> ~/dotfiles/.defaults'

# init rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# initialize z (https://github.com/rupa/z)
source ~/dotfiles/code/z/z.sh

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

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# if possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# sets gitconfig email based on computer in use (work v. home)
if [ ${HOME} == "/Users/morganwigmanich" ]; then
  git config --global user.email mwigmanich@patientslikeme.com
else
  git config --global user.email okize123@gmail.com
fi