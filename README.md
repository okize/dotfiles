# Okize dotfiles

## Installation

1. install Xcode via App Store

2. install Xcode command line tools (so that Git is installed)

```sh
xcode-select --install
```

3. clone this repo

```sh
git clone https://github.com/okize/dotfiles.git
```

4. run setup script

```sh
cd dotfiles && source bootstrap.sh
```

5. configure iTerm

iTerm2 > Preferences > General > Preferences > check `Load preferences from a custom folder or URL` and set to `~/dotfiles/iterm`
