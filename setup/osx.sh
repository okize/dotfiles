#!/usr/bin/env bash

# Ask for the administrator password upfront and run a keep-alive
# to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

echo ""
echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "What would you like it to be?"
  read COMPUTER_NAME
  sudo scutil --set ComputerName $COMPUTER_NAME
  sudo scutil --set HostName $COMPUTER_NAME
  sudo scutil --set LocalHostName $COMPUTER_NAME
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
fi

echo "Installing xcode command line tools..."
xcode-select --install

echo "Setting up OS X defaults..."

echo "Disable the sound effects on boot"
sudo nvram SystemAudioVolume=" "

echo "Set highlight color to green"
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

echo "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

echo "Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Remove duplicates in the “Open With” menu (also see `lscleanup` alias)"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Disable Resume system-wide"
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

echo "Disable automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo "Disable the crash reporter"
defaults write com.apple.CrashReporter DialogType -string "none"

echo "Set Help Viewer windows to non-floating mode"
defaults write com.apple.helpviewer DevMode -bool true

echo "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "Restart automatically if the computer freezes"
sudo systemsetup -setrestartfreeze on

echo "Never go into computer sleep mode"
sudo systemsetup -setcomputersleep Off > /dev/null

echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Disable smart quotes & dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Prime locate database"
launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

echo "Disable Notification Center and remove the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

###############################################################################
# Menu bar                                                                    #
###############################################################################

echo "Menu bar: hide the Bluetooth, Time Machine and User icons"
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu"
done
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"

echo "Menu bar: show battery percentage remaining"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

echo "Menu bar: show month & day next to time"
defaults write com.apple.menuextra.clock DateFormat -string "MMM d  h:mm a"

echo "Menu bar: disable transparency (also elsewhere on Yosemite)"
defaults write com.apple.universalaccess reduceTransparency -bool true

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

echo "Set a fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 0

echo "Set trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

echo "Trackpad: disable tap to click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 0
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
echo "Trackpad: disable three finger tap (look up)"
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0

# echo "Disable “natural” (Lion-style) scrolling"
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Use scroll gesture with the Ctrl (^) modifier key to zoom"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

echo "Follow the keyboard focus while zoomed in"
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

echo "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Set language and text formats"
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

echo "Set the timezone; see `sudo systemsetup -listtimezones` for other values"
sudo systemsetup -settimezone "America/New_York" > /dev/null

# echo "Disable auto-correct"
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300

###############################################################################
# Screen                                                                      #
###############################################################################

echo "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo "Enable HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Screenshots                                                                 #
###############################################################################

echo "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

echo "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

echo "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

echo "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons"
defaults write com.apple.finder QuitMenuItem -bool true

echo "Finder: disable window animations and Get Info animations"
defaults write com.apple.finder DisableAllAnimations -bool true

echo "Set Desktop as the default location for new Finder windows"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

echo "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "Finder: show hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "Finder: allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

echo "Remove the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0

echo "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

echo "Show item info near icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

echo "Show item info to the right of the icons on the desktop"
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

echo "Enable snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo "Increase grid spacing for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

echo "Increase the size of icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

echo "Use column view in all Finder windows by default"
# Four-letter codes for the view modes: `icnv`, 'Nlsv', `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

echo "Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

echo "Empty Trash securely by default"
defaults write com.apple.finder EmptyTrashSecurely -bool true

echo "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

echo "Enable the MacBook Air SuperDrive on any Mac"
sudo nvram boot-args="mbasd=1"

echo "Show the ~/Library folder"
chflags nohidden ~/Library

echo "Remove Dropbox’s green checkmark icons in Finder"
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

echo "Expand the following File Info panes:"
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

###############################################################################
# Dock
###############################################################################

echo "Wipe all (default) app icons from the Dock; this is only really useful when setting up a new Mac"
defaults write com.apple.dock persistent-apps -array

echo "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

echo "Set the icon size of Dock items to 36 pixels"
defaults write com.apple.dock tilesize -int 36

echo "Move the dock to the left-side of screen"
defaults write com.apple.dock orientation -string "left"

echo "Move the dock to the upper-left corner"
# this does not appear to work in Yosemite
defaults write com.apple.dock pinning -string start

echo "Change minimize/maximize window effect"
defaults write com.apple.dock mineffect -string "scale"

echo "Minimize windows into their application’s icon"
defaults write com.apple.dock minimize-to-application -bool true

echo "Enable spring loading for all Dock items"
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

echo "Don’t animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false

echo "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

echo "Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0

echo "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

# echo "Add a spacer to the left side of the Dock (where the applications are)"
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'

# echo "Add a spacer to the right side of the Dock (where the Trash is)"
# "defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

dockutil --no-restart --remove all
dockutil --no-restart --position 1 --add "/Applications/Google Chrome.app"
dockutil --no-restart --position 2 --add "/Applications/Google Chrome Canary.app"
dockutil --no-restart --position 3 --add "/Applications/Sublime Text.app"
dockutil --no-restart --position 4 --add "/Applications/iTerm.app"
dockutil --no-restart --position 5 --add "/Applications/Adium.app"
dockutil --no-restart --position 6 --add "/Applications/Slack.app"
dockutil --no-restart --position 7 --add "/Applications/Evernote.app"
dockutil --no-restart --position 8 --add "/Applications/SelfControl.app"
dockutil --no-restart --position 9 --add "/Applications/Messages.app"
dockutil --no-restart --position 10 --add "/Applications/Calendar.app.app"
dockutil --no-restart --position 11 --add '~/Downloads' --view grid --display folder

###############################################################################
# Mission Control, Dashboard, and hot corners                                 #
###############################################################################

echo "Speed up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1

echo "Group windows by application in Mission Control"
defaults write com.apple.dock "expose-group-by-app" -bool true

echo "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

echo "Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true

echo "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

echo "Reset Launchpad, but keep the desktop wallpaper intact"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

echo "Add iOS Simulator to Launchpad"
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

# echo "Top left screen corner → Mission Control"
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0

# echo "Top right screen corner → Desktop"
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0

echo "Bottom left screen corner → Start screen saver"
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# echo "Bottom right screen corner → Show application windows"
# defaults write com.apple.dock wvous-br-corner -int 3
# defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# iTerm & Terminal                                                            #
###############################################################################

echo "Set iterm to use saved settings"
defaults write com.googlecode.iterm2 PrefsCustomFolder "/Users/morganwigmanich/dotfiles/iterm2"

echo "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

echo "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"

# echo "Disable the all too sensitive backswipe on trackpads"
# defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
# defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# echo "Disable the all too sensitive backswipe on Magic Mouse"
# defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
# defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

echo "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

echo "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo "Privacy: don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "Press Tab to highlight each item on a web page"
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

echo "Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo "Set Safari’s home page to `about:blank` for faster loading"
defaults write com.apple.Safari HomePage -string "about:blank"

echo "Prevent Safari from opening ‘safe’ files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# echo "Allow hitting the Backspace key to go to the previous page in history"
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

echo "Hide Safari’s bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "Hide Safari’s sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo "Disable Safari’s thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

echo "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo "Make Safari’s search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo "Remove useless icons from Safari’s bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

echo "Enable the Developer menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Messages                                                                    #
###############################################################################

echo "Disable automatic emoji substitution (i.e. use plain text smileys)"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

echo "Disable smart quotes as it’s annoying for messages that contain code"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

echo "Disable continuous spell checking"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

echo "Enable the debug menu in Address Book"
defaults write com.apple.addressbook ABShowDebugMenu -bool true

echo "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
defaults write com.apple.dashboard devmode -bool true

echo "Enable the debug menu in iCal (pre-10.8)"
defaults write com.apple.iCal IncludeDebugMenu -bool true

echo "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0

echo "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

echo "Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

echo "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5

echo "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Mail                                                                        #
###############################################################################

echo "Disable send and reply animations in Mail.app"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

echo "Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

echo "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

echo "Display emails in threaded mode, sorted by date (oldest at the top)"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

echo "Disable inline attachments (just show the icons)"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

# echo "Disable automatic spell checking"
# defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

echo "Disable local Time Machine snapshots"
sudo tmutil disablelocal

echo "Disable hibernation (speeds up entering sleep mode)"
sudo pmset -a hibernatemode 0

# echo "Remove the sleep image file to save disk space"
# sudo rm /private/var/vm/sleepimage

# echo "Create a zero-byte file instead…"
# sudo touch /private/var/vm/sleepimage

# echo "…and make sure it can’t be rewritten"
# sudo chflags uchg /private/var/vm/sleepimage

echo "Disable the sudden motion sensor as it’s not useful for SSDs"
sudo pmset -a sms 0

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Firefox" "iCal"\
  "iTerm" "Mail" "Messages" "SystemUIServer"; do
  killall "${app}" > /dev/null 2>&1
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
