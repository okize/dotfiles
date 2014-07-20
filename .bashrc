# path settings
HOMEBREW=/usr/local/bin:/usr/local/lib:/usr/local/sbin
GIT=/usr/local/git/bin
NODE=/usr/local/share/npm/bin:/usr/local/share/npm/lib/node_modules
HEROKU=/usr/local/heroku/bin
GO=/usr/local/go/bin
RBENV=$HOME/.rbenv/bin
export PATH=$HOMEBREW:$GIT:$NODE:$HEROKU:$GO:$RBENV:$PATH

# loads dotfiles into shell
# ~/.extra used for settings I don’t want to commit
for file in ~/.{bash_prompt,aliases,gitaliases,functions,exports,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

# init rbenv
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# init z (https://github.com/rupa/z)
if [ -f ~/dotfiles/code/z/z.sh ]; then
    . ~/dotfiles/code/z/z.sh
fi

# tab completion for Git
if [ -f ~/dotfiles/code/git-completion/git-completion.bash ]; then
  . ~/dotfiles/code/git-completion/git-completion.bash
fi

# tab completion for homebrew
if [ -f ~/dotfiles/code/homebrew/brew-completion.sh ]; then
    . ~/dotfiles/code/homebrew/brew-completion.sh
fi

# tab completion for gulp
if [ -f ~/dotfiles/code/gulp/gulp-completion.sh ]; then
    . ~/dotfiles/code/gulp/gulp-completion.sh
fi

# tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# killall tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# if possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# sets gitconfig email based on computer in use (work v. home)
if [ ${HOME} == "/Users/mwigmanich" ]; then
  git config --global user.email okize123@gmail.com
else
  git config --global user.email mwigmanich@patientslikeme.com
fi