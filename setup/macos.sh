#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we're about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront and run a keep-alive
# to update existing `sudo` time stamp until script has finished
sudo -v

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

log_section "Setting up macOS defaults"

log_step "Disable the sound effects on boot"
sudo nvram SystemAudioVolume=" "

log_step "Set highlight color to green"
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

log_step "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

log_step "Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

log_step "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

log_step "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

log_step "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

log_step "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

log_step "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

log_step "Remove duplicates in the “Open With” menu"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

log_step "Disable Resume system-wide"
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

log_step "Disable automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

log_step "Disable the crash reporter"
defaults write com.apple.CrashReporter DialogType -string "none"

log_step "Set Help Viewer windows to non-floating mode"
defaults write com.apple.helpviewer DevMode -bool true

log_step "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

log_step "Restart automatically if the computer freezes"
sudo systemsetup -setrestartfreeze on

log_step "Never go into computer sleep mode"
sudo systemsetup -setcomputersleep Off > /dev/null

log_step "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

log_step "Disable smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

log_step "Disable automatic capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

log_step "Disable smart dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

log_step "Disable automatic period substitution"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

log_step "Disable Notification Center and remove the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

###############################################################################
# Menu bar                                                                    #
###############################################################################

log_section "Menu bar settings"

log_step "hide the Bluetooth, Time Machine and User icons"
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
done
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Displays.menu" \
  "/System/Library/CoreServices/Menu Extras/Viscosity.menu" \
  "/System/Library/CoreServices/Menu Extras/UniversalAccess.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu" \
  "/System/Library/CoreServices/Menu Extras/User.menu"

log_step "show battery percentage remaining"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

log_step "show month & day next to time"
defaults write com.apple.menuextra.clock DateFormat -string "MMM d  h:mm a"

log_step "disable transparency"
# Could not write domain com.apple.universalaccess; exiting
# defaults write com.apple.universalaccess reduceTransparency -bool true

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

log_section "Trackpad, mouse, keyboard, etc"

log_step "Set keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 60
defaults write NSGlobalDomain InitialKeyRepeat -int 10

log_step "Set trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

log_step "Trackpad: disable tap to click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 0
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
log_step "Trackpad: disable three finger tap (look up)"
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0

log_step "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

log_step "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

log_step "Use scroll gesture with the Ctrl (^) modifier key to zoom"
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

log_step "Follow the keyboard focus while zoomed in"
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

log_step "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

log_step "Set language and text formats"
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

log_step "Set the timezone; see 'sudo systemsetup -listtimezones' for other values"
sudo systemsetup -settimezone "America/New_York" > /dev/null
sudo systemsetup -setnetworktimeserver "time.apple.com"
sudo systemsetup -setusingnetworktime on

# log_step "Disable auto-correct"
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

log_step "Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300

###############################################################################
# Screen                                                                      #
###############################################################################

log_section "Screen"

log_step "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

log_step "Enable subpixel font rendering on non-Apple LCDs"
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

log_step "Enable HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

log_step "Disable Font Smoothing Disabler in macOS Mojave"
# Reference: https://ahmadawais.com/fix-macos-mojave-font-rendering-issue/
defaults write -g CGFontRenderingFontSmoothingDisabled -bool FALSE

###############################################################################
# Screenshots                                                                 #
###############################################################################

log_step "Save screenshots to downloads"
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

log_step "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

log_step "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

log_section "Finder"

log_step "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons"
defaults write com.apple.finder QuitMenuItem -bool true

log_step "Finder: disable window animations and Get Info animations"
defaults write com.apple.finder DisableAllAnimations -bool true

log_step "Set Desktop as the default location for new Finder windows"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

log_step "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

log_step "Finder: show hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

log_step "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

log_step "Finder: show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

log_step "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

log_step "Finder: allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

log_step "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

log_step "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

log_step "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

log_step "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

log_step "Remove the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0

log_step "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

log_step "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

log_step "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

log_step "Show item info near icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

log_step "Show item info to the right of the icons on the desktop"
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

log_step "Enable snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

log_step "Increase grid spacing for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

log_step "Increase the size of icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

log_step "Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

log_step "Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

log_step "Empty Trash securely by default"
defaults write com.apple.finder EmptyTrashSecurely -bool true

log_step "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

log_step "Show the ~/Library folder"
chflags nohidden ~/Library

log_step "Remove Dropbox's green checkmark icons in Finder"
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

log_step "Expand 'File Info' panes:"
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

###############################################################################
# Dock
###############################################################################

log_section "Dock"

log_step "Wipe all (default) app icons from the Dock"
# this is only really useful when setting up a new Mac
defaults write com.apple.dock persistent-apps -array

log_step "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

log_step "Set the icon size of Dock items to 36 pixels"
defaults write com.apple.dock tilesize -int 36

log_step "Move the dock to the left-side of screen"
defaults write com.apple.dock orientation -string "left"

log_step "Move the dock to the upper-left corner"
# this does not appear to work in Yosemite
defaults write com.apple.dock pinning -string start

log_step "Change minimize/maximize window effect"
defaults write com.apple.dock mineffect -string "scale"

log_step "Minimize windows into their application's icon"
defaults write com.apple.dock minimize-to-application -bool true

log_step "Enable spring loading for all Dock items"
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

log_step "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

log_step "Don't animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false

log_step "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

log_step "Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0

log_step "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

log_step "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

log_step "Don’t show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

# log_step "Add a spacer to the left side of the Dock (where the applications are)"
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'

# log_step "Add a spacer to the right side of the Dock (where the Trash is)"
# "defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

dockutil --no-restart --remove all
dockutil --no-restart --position 1 --add "/Applications/Google Chrome.app"
dockutil --no-restart --position 3 --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --position 4 --add "/Applications/iTerm.app"
dockutil --no-restart --position 5 --add "/Applications/Slack.app"
dockutil --no-restart --position 6 --add "/Applications/Insomnia.app"
dockutil --no-restart --position 9 --add "/Applications/SelfControl.app"
dockutil --no-restart --position 10 --add "/Applications/Evernote.app"
dockutil --no-restart --position 11 --add "/Applications/MacDown.app"
dockutil --no-restart --position 12 --add "/Applications/Messages.app"
dockutil --no-restart --position 13 --add "/Applications/Calendar.app"
dockutil --no-restart --position 14 --add '~/Downloads' --view grid --display folder

###############################################################################
# iTerm & Terminal                                                            #
###############################################################################

log_section "iTerm"

log_step "Set iterm to use saved settings"
defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/dotfiles/iterm"

log_step "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Messages                                                                    #
###############################################################################

log_section "Messages"

# log_step "Disable automatic emoji substitution (i.e. use plain text smileys)"
# defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

log_step "Disable smart quotes as it's annoying for messages that contain code"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

log_step "Disable continuous spell checking"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Google Chrome                                                               #
###############################################################################

log_section "Browsers"

log_step "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"

# log_step "Disable the all too sensitive backswipe on trackpads"
# defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

# log_step "Disable the all too sensitive backswipe on Magic Mouse"
# defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false

log_step "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true

log_step "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

log_step "Privacy: don't send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

log_step "Enable 'Do Not Track'"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

log_step "Press Tab to highlight each item on a web page"
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

log_step "Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

log_step "Set Safari's home page to 'about:blank' for faster loading"
defaults write com.apple.Safari HomePage -string "about:blank"

log_step "Prevent Safari from opening ‘safe' files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# log_step "Allow hitting the Backspace key to go to the previous page in history"
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

log_step "Hide Safari's bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false

log_step "Hide Safari's sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

log_step "Disable Safari's thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

log_step "Enable Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

log_step "Make Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

log_step "Remove useless icons from Safari's bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

log_step "Enable the Developer menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

log_step "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

log_section "Activity Monitor"

###############################################################################
# Activity Monitor                                                            #
###############################################################################

log_step "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

log_step "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5

log_step "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

log_step "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Mail                                                                        #
###############################################################################

log_section "Mail"

log_step "Disable send and reply animations in Mail.app"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

log_step "Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

log_step "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

log_step "Display emails in threaded mode, sorted by date (oldest at the top)"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

log_step "Disable inline attachments (just show the icons)"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

# log_step "Disable automatic spell checking"
# defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

###############################################################################
# Mission Control, Dashboard, and hot corners                                 #
###############################################################################

log_section "Misc"

log_step "Speed up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1

log_step "Group windows by application in Mission Control"
defaults write com.apple.dock "expose-group-by-app" -bool true

log_step "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

log_step "Don't show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true

log_step "Don't automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

log_step "Reset Launchpad, but keep the desktop wallpaper intact"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

log_step "Add iOS Simulator to Launchpad"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/iOS Simulator.app" "/Applications/iOS Simulator.app"

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen

# log_step "Top left screen corner → Mission Control"
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0

# log_step "Top right screen corner → Desktop"
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0

log_step "Bottom left screen corner → Lock screen"
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-bl-modifier -int 0

# log_step "Bottom right screen corner → Show application windows"
# defaults write com.apple.dock wvous-br-corner -int 3
# defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

log_step "Enable the debug menu in Address Book"
defaults write com.apple.addressbook ABShowDebugMenu -bool true

log_step "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
defaults write com.apple.dashboard devmode -bool true

log_step "Enable the debug menu in iCal (pre-10.8)"
defaults write com.apple.iCal IncludeDebugMenu -bool true

log_step "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0

log_step "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

log_step "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

log_step "Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

log_step "Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true

log_step "Enable the automatic update check"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

log_step "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

log_step "Download newly available updates in background"
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

log_step "Install System data files & security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# log_step "Automatically download apps purchased on other Macs"
# defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# log_step "Turn on app auto-update"
# defaults write com.apple.commerce AutoUpdate -bool true

# log_step "Allow the App Store to reboot machine on macOS updates"
# defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################

log_step "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

log_step "Disable local Time Machine backups"
hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

log_step "Disable hibernation (speeds up entering sleep mode)"
sudo pmset -a hibernatemode 0

# log_step "Remove the sleep image file to save disk space"
# sudo rm /private/var/vm/sleepimage

# log_step "Create a zero-byte file instead…"
# sudo touch /private/var/vm/sleepimage

# log_step "…and make sure it can't be rewritten"
# sudo chflags uchg /private/var/vm/sleepimage

log_step "Disable the sudden motion sensor as it's not useful for SSDs"
sudo pmset -a sms 0

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
  "Address Book" \
  "Calendar" \
  "cfprefsd" \
  "Contacts" \
  "Dock" \
  "Finder" \
  "iTerm" \
  "Mail" \
  "Messages" \
  "Photos" \
  "Safari" \
  "SizeUp" \
  "Spectacle" \
  "SystemUIServer" \
  "Terminal" \
  "iCal"; do
  killall "${app}" &> /dev/null
done
echo "$(tput bold)Done. Note that some of these changes require a logout/restart to take effect.$(tput sgr 0)"
