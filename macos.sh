#!/usr/bin/env zsh

###
# Cruft
###

osascript -e 'tell application "System Preferences" to quit' # Close any open System Preferences panes, to prevent them from overriding settings we’re about to change

sudo -v # Ask for the administrator password upfront

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null & # Keep-alive: update existing `sudo` time stamp until `.macos` has finished

/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist # Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist # Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist # Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist # Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist # Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist # Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist # Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist # Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist # Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist # Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist # Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist # Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist # Show item info to the bottom of the icons on the desktop
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true # Use scroll gesture with the Ctrl (^) modifier key to zoom
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true # Use scroll gesture with the Ctrl (^) modifier key to zoom. Follow the keyboard focus while zoomed in
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144 # Use scroll gesture with the Ctrl (^) modifier key to zoom
# Hot corners. Possible values: 0: no-op. 2: Mission Control. 3: Show application windows. 4: Desktop. 5: Start screen saver. 6: Disable screen saver. 7: Dashboard. 10: Put display to sleep. 11: Launchpad. 12: Notification Center. 13: Lock Screen.
defaults -currentHost write com.apple.screensaver idleTime -int 0 # System Preferences > Desktop & Screen Saver > Start after: Never
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 # System Preferences > Trackpad > Tap to click (also for login screen)
defaults write -globalDomain AppleScrollerPagingBehavior -bool true # System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
defaults write -globalDomain NSTableViewDefaultSizeMode -int 2 # System Preferences > General > Sidebar icon size: Medium
defaults write com.apple.ActivityMonitor IconType -int 5 # Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true # Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0 # Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage" # Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortDirection -int 0 # Sort Activity Monitor results by CPU usage
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false # System Preferences > Accessibility > Mouse & Trackpad > Trackpad Potions
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true # System Preferences > Accessibility > Mouse & Trackpad > Trackpad Potions
defaults write com.apple.appstore ShowDebugMenu -bool true # Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true # Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40 # Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.commerce AutoUpdate -bool true # Turn on app auto-update
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true # Allow the App Store to reboot machine on macOS updates
defaults write com.apple.dashboard mcx-disabled -bool true # Disable Dashboard
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true # Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.DiskUtility advanced-image-options -bool true # Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true # Enable the debug menu in Disk Utility
defaults write com.apple.dock autohide -bool true # System Preferences > Dock > Automatically hide and show the Dock:
defaults write com.apple.dock autohide-delay -float 0 # System Preferences > Dock > Automatically hide and show the Dock (delay)
defaults write com.apple.dock autohide-time-modifier -float 0 # System Preferences > Dock > Automatically hide and show the Dock (duration)
defaults write com.apple.dock dashboard-in-overlay -bool true # Don’t show Dashboard as a Space
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true # Enable spring loading for all Dock items
defaults write com.apple.dock expose-animation-duration -float 0.1 # Speed up Mission Control animations
defaults write com.apple.dock expose-group-by-app -bool false # Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock launchanim -bool false # Don’t animate opening applications from the Dock
defaults write com.apple.dock magnification -bool false # System Preferences > Dock > Magnification:
defaults write com.apple.dock mineffect -string "scale" # System Preferences > Dock > Minimize windows using: Scale effect
defaults write com.apple.dock minimize-to-application -bool true # System Preferences > Dock > Minimize windows into application icon
defaults write com.apple.dock mouse-over-hilite-stack -bool true # Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mru-spaces -bool true # System Preferences > Mission Control > Automatically rearrange Spaces based on most recent use
defaults write com.apple.dock persistent-apps -array # Wipe all (default) app icons from the Dock. This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
defaults write com.apple.dock show-process-indicators -bool true # System Preferences > Dock > Show indicators for open applications
defaults write com.apple.dock show-recents -bool false # Don’t show recent applications in Dock
defaults write com.apple.dock static-only -bool true # Show only open applications in the Dock
defaults write com.apple.dock tilesize -int 32 # Set the icon size of Dock items to 32 pixels
defaults write com.apple.dock wvous-bl-corner -int 2 # Bottom left screen corner → Mission Control
defaults write com.apple.dock wvous-bl-corner -int 4 # Bottom left screen corner → Desktop
defaults write com.apple.dock wvous-bl-modifier -int 0 # Bottom left screen corner → Desktop
defaults write com.apple.dock wvous-bl-modifier -int 0 # Bottom left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 3 # Top left screen corner → Show application windows
defaults write com.apple.dock wvous-tl-modifier -int 0 # Top left screen corner → Show application windows
defaults write com.apple.dock wvous-tr-corner -int 13 # Top right screen corner → Lock Screen
defaults write com.apple.dock wvous-tr-modifier -int 0 # Top right screen corner → Lock Screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true # System Preferences > Trackpad > Tap to click (also for login screen)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false # System Preferences > Accessibility > Mouse & Trackpad > Trackpad Potions
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true # System Preferences > Accessibility > Mouse & Trackpad > Trackpad Potions
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true # Display full POSIX path as Finder window title
defaults write com.apple.finder _FXSortFoldersFirst -bool true # Keep folders on top when sorting by name
defaults write com.apple.finder AppleShowAllFiles -bool true # Finder: show hidden files by default
defaults write com.apple.finder DisableAllAnimations -bool true # Finder: disable window animations and Get Info animations
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # When performing a search, search the current folder by default
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false # Finder > Preferences > Show wraning before changing an extension
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false # Finder > Preferences > Show warning before removing from iCloud Drive
defaults write com.apple.finder FXPreferredViewStyle -string "clmv" # Use Column View in all Finder windows by default. Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder NewWindowTarget -string "PfDe" # Set Desktop as the default location for new Finder windows. For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/" # Set Desktop as the default location for new Finder windows. For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true # Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true # Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true # Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowPathbar -bool false # Finder > View > Show Path Bar
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true # Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowStatusBar -bool true # Finder: show status bar
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true # Disable inline attachments (just show the icons)
defaults write com.apple.mail DisableReplyAnimations -bool true # Disable send and reply animations in Mail.app
defaults write com.apple.mail DisableSendAnimations -bool true # Disable send and reply animations in Mail.app
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes" # Display emails in threaded mode, sorted by date (oldest at the top)
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes" # Display emails in threaded mode, sorted by date (oldest at the top)
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date" # Display emails in threaded mode, sorted by date (oldest at the top)
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "\033Message\033Archive" -string "@e" # Command-E
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9" # Command-Enter
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9" # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false # Disable smart quotes
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true # Automatically quit printer app once the print jobs complete
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true # Auto-play videos when opened with QuickTime Player
defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "\033Window\033Show Next Tab" -string "@~\\U2192" # Command-Alt-Right
defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "\033Window\033Show Previous Tab" -string "@~\\U2190" # Command-Alt-Left
defaults write com.apple.screencapture disable-shadow -bool true # Disable shadow in screenshots
defaults write com.apple.screencapture location -string "${HOME}/Documents/Screenshots" # Save screenshots to the desktop
defaults write com.apple.screencapture type -string "png" # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screensaver askForPassword -int 1 # Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPasswordDelay -int 0 # Require password immediately after sleep or screen saver begins
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true # Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1 # Download newly available updates in background
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1 # Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1 # Install System data files & security updates
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1 # Check for software updates daily, not just once per week
defaults write com.apple.terminal SecureKeyboardEntry -bool true # Enable Secure Keyboard Entry in Terminal.app. See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.Terminal ShowLineMarks -int 0 # Disable line marks
defaults write com.apple.terminal StringEncodings -array 4 # Only use UTF-8 in Terminal.app
defaults write com.apple.TextEdit PlainTextEncoding -int 4 # Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 # Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit RichText -int 0 # Use plain text mode for new TextEdit documents
defaults write com.apple.universalaccess reduceTransparency -bool true # Disable transparency in the menu bar and elsewhere
defaults write NSGlobalDomain _HIHideMenuBar -bool true # Auto-hide the menu bar
defaults write NSGlobalDomain AppleLanguages -array "en" "da" # Set language and text formats
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR" # Set language and text formats
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters" # Set language and text formats
defaults write NSGlobalDomain AppleMetricUnits -bool true # Set language and text formats
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain AppleShowAllExtensions -bool true # Finder > Preferences > Show all filename extensions
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling" # Always show scrollbars. Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 # System Preferences > Trackpad > Tap to click (also for login screen)
defaults write NSGlobalDomain com.apple.springing.delay -float 0 # Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true # Enable spring loading for directories
defaults write NSGlobalDomain InitialKeyRepeat -int 20 # System Preferences > Keyboard > Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1 # System Preferences > Keyboard > Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false # Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false # Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true # Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true # Expand save panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true # Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true # Expand print panel by default
defaults write pro.writer.mac NSCloseAlwaysConfirmsChanges -bool false # Enable "auto-save" in iA Writer
sudo chflags nohidden /Volumes # Show the /Volumes folder
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true # Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $(scutil --get HostName) # Set computer name (as done via System Preferences → Sharing)
sudo nvram SystemAudioVolume=" " # Disable the sound effects on boot
sudo pmset -a displaysleep 10 # Sleep the display after 10 minutes
sudo pmset -b sleep 15 # Set machine sleep to 15 minutes on battery
sudo pmset -c sleep 0 # Disable machine sleep while charging
sudo scutil --set ComputerName "marks macbook pro" # Set computer name (as done via System Preferences → Sharing)
sudo scutil --set HostName "marks-macbook-pro" # Set computer name (as done via System Preferences → Sharing)
sudo scutil --set LocalHostName $(scutil --get HostName) # Set computer name (as done via System Preferences → Sharing)
sudo systemsetup -settimezone "Europe/Copenhagen" > /dev/null # Set the timezone; see `sudo systemsetup -listtimezones` for other values

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" > /dev/null 2>&1
done

# Done
echo "Done. Note that some of these changes require a logout/restart to take effect."
