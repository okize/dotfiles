#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# General UI/UX

# Set computer name (as done via System Preferences → Sharing)
# sudo scutil --set ComputerName 'MastaShake'
# sudo scutil --set HostName ''
# sudo scutil --set LocalHostName 'MacBookPro'
# sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "0x6D746873"

# Set highlight color to green
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Reveal IP address, hostname, etc. when clicking the clock in the login window
defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Make Hidden App Icons Translucent in the Dock
defaults write com.apple.Dock showhidden -bool YES && killall Dock

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Remove the Auto-Hide Dock Delay
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock

# Speed Up Mission Control Animations
defaults write com.apple.dock expose-animation-duration -float 0.12 && killall Dock

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Enable Text Selection in Quick Look Windows
defaults write com.apple.finder QLEnableTextSelection -bool TRUE;killall Finder

# Change Where Screen Shots Are Saved To
defaults write com.apple.screencapture location ~/Documents/Screenshots

# Show System Info at the Login Screen
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Use column view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`
defaults write com.apple.Finder FXPreferredViewStyle -string "clmv"

# Show the ~/Library folder
chflags nohidden ~/Library

#Desktop settings
defaults write com.apple.DesktopViewSettings.IconViewSettings arrangeBy -string "name"
defaults write com.apple.DesktopViewSettings.IconViewSettings iconSize -int 64
defaults write com.apple.DesktopViewSettings.IconViewSettings gridSpacing -int 100
defaults write com.apple.DesktopViewSettings.IconViewSettings textSize -int 12
defaults write com.apple.DesktopViewSettings.IconViewSettings labelOnBottom -bool false

# Dock settings

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.Dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.1

# Scale windows when minimizing
defaults write com.apple.dock mineffect "scale"

# Tile size 50
defaults write com.apple.dock tilesize -int 50