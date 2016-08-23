#!/bin/bash
# install a DMG from CLI
# Author Ryan Nolette
# Date Modified 06/26/2016
######################################################################
function audit_WithOutput () {

	if [[ $2 ]]; then
	    echo "$1,pass" >> $filename
	else
	    echo "$1,fail" >> $filename
	fi
}
function audit_WithNoOutput () {

	if [[ $2 ]]; then
		echo "$1,fail" >> $filename
	else
		echo "$1,pass" >> $filename
	fi
}
function audit_Exception () {
	echo "$1,exception" >> $filename
}
#####################################################################
#get hostname
host=`hostname`
#get current date
dateTime=`date +"%m%d%y-%H%M"`
#create filename
filename="CIS_MacOSX-"$host"-"$dateTime".csv"
#create new file
touch $filename
#####################################################################
#1 Install Updates, Patches and Additional Security Software
#1.1 Verify all application software is current
auditStep="1.1 Verify all application software is current (Scored)"
#auditCmd=`softwareupdate -l |grep -i "No new software available."`
authdCmd=``
audit_Exception "$auditStep" "$auditCmd"
#1.2 Enable Auto Update (Scored)
auditStep="1.2 Enable Auto Update (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled |grep 1`
audit_WithOutput "$auditStep" "$auditCmd"
#1.3 Enable app update installs (Scored)
auditStep="1.3 Enable app update installs (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.storeagent.plist |grep 1`
audit_WithOutput  "$auditStep" "$auditCmd"
#1.4 Enable system data files and security update installs (Scored)
auditStep="1.4 Enable system data files and security update installs (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.SoftwareUpdate | egrep '(ConfigDataInstall = 1 |CriticalUpdateInstall = 1)'`
#Make sure the result is: ConfigDataInstall = 1; CriticalUpdateInstall = 1
audit_WithOutput  "$auditStep" "$auditCmd"
######################################################################
#2 System Preferences
#2.1 Bluetooth
#2.1.1 Disable Bluetooth, if no paired devices exist (Scored)
auditStep="2.1.1 Disable Bluetooth if no paired devices exist (Scored)"
#auditCmd=`defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState | grep "0"`
auditCmd=``
audit_Exception "$auditStep - Security chose not to disable" "$auditCmd"
#2.1.2 Disable Bluetooth "Discoverable" mode when not pairing devices (Scored) - Is not applicable to servers because they do not have Bluetooth.
auditStep="2.1.2 Disable Bluetooth \"Discoverable\" mode when not pairing devices (Scored)"
#auditCmd=`/usr/sbin/system_profiler SPBluetoothDataType | grep -i discoverable`
auditCmd=``
audit_Exception "$auditStep - Security chose not to disable" "$auditCmd"
#2.1.3 Show Bluetooth status in menu bar (Scored)
auditStep="2.1.3 Show Bluetooth status in menu bar (Scored)" #is not applicable to servers because they do not have screen savers.
#auditCmd=`defaults read com.apple.systemuiserver menuExtras | grep Bluetooth.menu`
auditCmd=``
audit_Exception "$auditStep - Security chose not to disable" "$auditCmd"
#2.2 Date & Time
#2.2.1 Enable "Set time and date automatically" (Not Scored)
auditStep="2.2.1 Enable Set time and date automatically (Not Scored)"
auditCmd=`systemsetup -setnetworktimeserver on | grep -E "setNetworkTimeServer:\s+on"`
audit_WithOutput "$auditStep" "$auditCmd"
#2.2.2 Ensure time set is within appropriate limits (Scored)
##########################
auditStep="2.2.2 Ensure time set is within appropriate limits (Scored)"
auditCmd=`systemsetup -getnetworktimeserver | grep -E "Network\s+Time\s+Server:\s+on"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#2.3 Desktop & Screen Saver
#2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)
auditStep="2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)"
auditCmd=`defaults -currentHost read com.apple.screensaver |grep -E "idleTime\s+=\s+600"`
audit_WithOutput "$auditStep" "$auditCmd"
#2.3.2 Secure screen saver corners (Scored)
#exception because of servers
auditStep="2.3.2 Secure screen saver corners (Scored)"
#auditCmd=`defaults read /Library/Preferences/com.apple.dock | grep -i corner`
auditCmd=``
audit_Exception "$auditStep - casper enforced" "$auditCmd"
#2.3.3 Verify Display Sleep is set to a value larger than the Screen Saver (Not Scored)
auditStep="2.3.3 Verify Display Sleep is set to a value larger than the Screen Saver (Not Scored)" #is not applicable to servers because they do not have screen savers.
#auditCmd=`/usr/bin/pmset -g | grep -iE "displaysleep\s+15"`
auditCmd=``
audit_Exception "$auditStep - casper enforced" "$auditCmd"
#2.3.4 Set a screen corner to Start Screen Saver (Scored)
auditStep="2.3.4 Set a screen corner to Start Screen Saver (Scored)" #is not applicable to servers because they do not have screen savers.
#auditCmd=`defaults read /Library/Preferences/com.apple.dock | grep -i corner`
#This is trypically run for each user of the system.  The only user for this system is Build
auditCmd=``
audit_Exception "$auditStep - casper enforced" "$auditCmd"
##########################
#2.4 Sharing
#2.4.1 Disable Remote Apple Events (Scored)
auditStep="2.4.1 Disable Remote Apple Events (Scored)"
auditCmd=`systemsetup -getremoteappleevents |grep -E "Remote\s+Apple\s+Events:\s+Off"`
audit_WithOutput "$auditStep" "$auditCmd"
#2.4.2 Disable Internet Sharing (Scored)
auditStep="2.4.2 Disable Internet Sharing (Scored) - grep not working correctly on this commands output"
#auditCmd=`defaults read /Library/Preferences/SystemConfiguration/com.apple.nat | grep -E "com.apple.nat\s+does\s+not\s+exist"`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.4.3 Disable Screen Sharing (Scored)
auditStep="2.4.3 Disable Screen Sharing (Scored)"
auditCmd=`launchctl list | grep com.apple.screensharing`
audit_WithNoOutput "$auditStep" "$auditCmd"
#2.4.4 Disable Printer Sharing (Scored)
auditStep="2.4.4 Disable Printer Sharing (Scored)"
auditCmd=`system_profiler SPPrintersDataType | grep "Status: The printers list is empty."`
audit_WithOutput "$auditStep" "$auditCmd"
#2.4.5 Disable Remote Login (Scored) #This is required for ssh login
auditStep="2.4.5 Disable Remote Login (Scored) - leaving enabled for ssh access to server"
auditCmd=``
audit_Exception "$auditStep - required by Security" "$auditCmd"
#2.4.6 Disable DVD or CD Sharing (Scored)
auditStep="2.4.6 Disable DVD or CD Sharing (Scored)"
auditCmd=`launchctl list | egrep ODSAgent`
audit_WithNoOutput "$auditStep" "$auditCmd"
#2.4.7 Disable Bluetooth Sharing (Scored)
auditStep="2.4.7 Disable Bluetooth Sharing (Scored)"
auditCmd=`system_profiler SPBluetoothDataType | grep -E "State: Enabled"`
audit_WithNoOutput "$auditStep" "$auditCmd"
#2.4.8 Disable File Sharing (Scored)
auditStep="2.4.8 Disable File Sharing (Scored)"
auditCmd=`launchctl list | egrep AppleFileServer`
audit_WithNoOutput "$auditStep" "$auditCmd"
#2.4.9 Disable Remote Management (Scored)
auditStep="2.4.9 Disable Remote Management (Scored)"
auditCmd=`ps -ef | egrep ARDAgent | grep -Eiv "grep ARDAgent"`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#2.5 Energy Saver
#2.5.1 Disable "Wake for network access" (Scored)
auditStep="2.5.1 Disable Wake for network access (Scored)" #This is not applicable because network connectivity does not goto sleep.
#auditCmd=`pmset -g | grep -i 'AC Power'`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.5.2 Disable sleeping the computer when connected to power (Scored)
auditStep="2.5.2 Disable sleeping the computer when connected to power (Scored)"
#auditCmd=`pmset -g | grep -E 'sleep\s+0|AC Power'`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#2.6 Security & Privacy
#2.6.1 Enable FileVault (Scored)
auditStep="2.6.1 Enable FileVault (Scored)"
#auditCmd=`diskutil cs list | grep -iE "Encryption\s+Type:\s+AES-XTS"`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.6.2 Enable Gatekeeper (Scored)
auditStep="2.6.2 Enable Gatekeeper (Scored)"
auditCmd=`spctl --status | grep "assessments enabled"`
audit_WithOutput "$auditStep" "$auditCmd"
#2.6.3 Enable Firewall (Scored)
auditStep="2.6.3 Enable Firewall (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.alf globalstate | grep "1"`
#<value> is: 1 = on for specific services, 2 = on for essential services
audit_WithOutput "$auditStep" "$auditCmd"
#2.6.4 Enable Firewall Stealth Mode (Scored)
auditStep="2.6.4 Enable Firewall Stealth Mode (Scored) - cannot be turned on and allow ssh inbound"
#auditCmd=`/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode |grep -i "Stealth mode enabled."`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.6.5 Review Application Firewall Rules (Scored)
auditStep="2.6.5 Review Application Firewall Rules (Scored)"
auditCmd=`/usr/libexec/ApplicationFirewall/socketfilterfw --listapps | sed -n 'p;$='`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#2.7 iCloud
#2.7.1 iCloud configuration (Not Scored)
auditStep="2.7.1 iCloud configuration (Not Scored)"
authdCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.7.2 iCloud keychain (Not Scored)
auditStep="2.7.2 iCloud keychain (Not Scored)"
authdCmd=``
audit_Exception "$auditStep" "$auditCmd"
#2.7.3 iCloud Drive (Scored)
auditStep="2.7.3 iCloud Drive (Scored)"
#auditCmd=`defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud |grep "0"`
authdCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#2.8 Pair the remote control infrared receiver if enabled (Scored)
auditStep="2.8 Pair the remote control infrared receiver if enabled (Scored)" #This is not applicable because servers do not utilize infrared technology.
auditCmd=`defaults read /Library/Preferences/com.apple.driver.AppleIRController | grep -E "DeviceEnabled\s+=\s+0;"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#2.9 Enable Secure Keyboard Entry in terminal.app (Scored)
auditStep="2.9 Enable Secure Keyboard Entry in terminal.app (Scored)"
auditCmd=`defaults read -app Terminal SecureKeyboardEntry | grep "1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#2.10 Java 8 is not the default Java runtime (Scored)  Java is not installed by default.
auditStep="2.10 Java 6 is not the default Java runtime (Scored)"
auditCmd=`pkgutil --packages | grep "com.oracle.*"`
#auditCmd=`java -version | grep `
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#2.11 Configure Secure Empty Trash (Scored)
auditStep="2.11 Configure Secure Empty Trash (Scored)" #This does not apply because this would indicate a gui is used for login accounts.  This is not the case on servers.
auditCmd=`defaults read ~/Library/Preferences/com.apple.finder EmptyTrashSecurely | grep "1"`
audit_WithOutput "$auditStep" "$auditCmd"
####################################################
#3 Logging and Auditing
#3.1 Configure asl.conf
#3.1.1 Retain system.log for 90 or more days (Scored)
auditStep="3.1.1 Retain system.log for 90 or more days (Scored)"
auditCmd=`grep -i "> system.log" /etc/asl.conf | egrep "system.log|tty=90"`
audit_WithOutput "$auditStep" "$auditCmd"
#3.1.2 Retain appfirewall.log for 90 or more days (Scored)
auditStep="3.1.2 Retain appfirewall.log for 90 or more days (Scored)"
auditCmd=`grep -i "appfirewall.log" /etc/asl.conf | grep -i "ttl=90"`
audit_WithOutput "$auditStep" "$auditCmd"
#3.1.3 Retain authd.log for 90 or more days (Scored)
auditStep="3.1.3 Retain authd.log for 90 or more days (Scored)"
auditCmd=`grep -i "authd.log" /etc/asl/com.apple.authd | egrep "authd.conf|ttl=90"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#3.2 Enable security auditing (Scored)
auditStep="3.2 Enable security auditing (Scored)"
auditCmd=`/bin/launchctl list | grep -i auditd | awk '{ print $3 }'`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#3.3 Configure Security Auditing Flags (Scored)
auditStep="3.3 Configure Security Auditing Flags (Scored)"
auditCmd=`egrep "^flags:" /etc/security/audit_control | egrep "^flags:lo,ad,fd,fm,-all"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#3.4 Enable remote logging for Desktops on trusted networks (Not Scored)
auditStep="3.4 Enable remote logging for Desktops on trusted networks (Not Scored) - using log forwarder for this"
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#3.5 Retain install.log for 365 or more days (Scored)
auditStep="3.5 Retain install.log for 365 or more days (Scored)"
auditCmd=`grep -i "ttl=365" /etc/asl/com.apple.install`
audit_WithOutput "$auditStep" "$auditCmd"
####################################################
#4 Network Configurations
#4.1 Enable "Show Wi-Fi status in menu bar" (Scored)
auditStep="4.1 Enable Show Wi-Fi status in menu bar (Scored) - no wifi on servers"
#auditCmd=`defaults read com.apple.systemuiserver menuExtras | grep AirPort.menu
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#4.2 Create network specific locations (Not Scored)
auditStep="4.2 Create network specific locations (Not Scored)" #This is not applicable in a server environment where vCenter controls network segment access
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#4.3 Ensure http server is not running (Scored)
auditStep="4.3 Ensure http server is not running (Scored)"
auditCmd=`launchctl list |egrep httpd`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#4.4 Ensure ftp server is not running (Scored)
auditStep="4.4 Ensure ftp server is not running (Scored)"
auditCmd=`launchctl list | egrep ftp`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#4.5 Ensure nfs server is not running (Scored)
auditStep="4.5 Ensure nfs server is not running (Scored)"
auditCmd=`launchctl list | egrep nfsd`
audit_WithNoOutput "$auditStep" "$auditCmd"
####################################################
#5 System Access, Authentication and Authorization
#5.1 File System Permissions and Access Controls
#5.1.1 Secure Home Folders (Scored)
auditStep="5.1.1 Secure Home Folders (Scored)"
auditCmd=`ls -l /Users/ | grep "^drwx------"`
audit_WithOutput "$auditStep" "$auditCmd"
#5.1.2 Repair permissions regularly to ensure binaries and other System files have appropriate permissions (Not Scored)
auditStep="5.1.2 Repair permissions regularly to ensure binaries and other System files have appropriate permissions (Not Scored) - not required on fresh install"
#auditCmd=`cat /var/log/system.log* | grep RepairPermissions`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
#5.1.3 Check System Wide Applications for appropriate permissions (Scored)
auditStep="5.1.3 Check System Wide Applications for appropriate permissions (Scored)"
auditCmd=`find /Applications -iname "*\.app" -type d -perm -2 -ls -fstype local`
audit_WithNoOutput "$auditStep" "$auditCmd"
#5.1.4 Check System folder for world writable files (Scored)
auditStep="5.1.4 Check System folder for world writable files (Scored)"
auditCmd=`find /System -type d -perm -2 -ls -fstype local | grep -v "Public/Drop Box"`
audit_WithNoOutput "$auditStep" "$auditCmd"
#5.1.5 Check Library folder for world writable files (Scored)
auditStep="5.1.5 Check Library folder for world writable files (Scored)"
auditCmd=`find /Library -type d -perm -2 -ls -fstype local | grep -v Caches`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#5.2 Reduce the sudo timeout period (Scored)
auditStep="5.2 Reduce the sudo timeout period (Scored)"
auditCmd=`cat /etc/sudoers | grep -E "Defaults\s+timestamp_timeout=0"`
#Verify the value returned is: Defaults timestamp_timeout=0
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.3 Automatically lock the login keychain for inactivity (Scored)
auditStep="5.3 Automatically lock the login keychain for inactivity (Scored)"
#auditCmd=`security show-keychain-info | grep -i "timeout=21600s"`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.4 Ensure login keychain is locked when the computer sleeps (Scored)
auditStep="5.4 Ensure login keychain is locked when the computer sleeps (Scored)"
#auditCmd=`security show-keychain-info | grep -i "lock-on-sleep"`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.5 Enable OCSP and CRL certificate checking (Scored)
auditStep="5.5 Enable OCSP and CRL certificate checking (Scored)"
auditCmd=`defaults read com.apple.security.revocation | egrep "CRLStyle = RequireIfPresent;|OCSPStyle = RequireIfPresent;"`
#This gives both output results for OCSPStyle and CRLStyle
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.6 Do not enable the "root" account (Scored)
auditStep="5.6 Do not enable the "root" account (Scored)"
auditCmd=`dscl . -read /Users/root | grep -q AuthenticationAuthority`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#5.7 Disable automatic login (Scored)
auditStep="5.7 Disable automatic login (Scored)"  #This is not applicable to server environments
auditCmd=`defaults read /Library/Preferences/com.apple.loginwindow | grep autoLoginUser`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#5.8 Require a password to wake the computer from sleep or screen saver (Scored)
auditStep="5.8 Require a password to wake the computer from sleep or screen saver (Scored)" #The is not applicable to server instances as they do not goto sleep
auditCmd=`defaults read com.apple.screensaver askForPassword | grep "1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.9 Require an administrator password to access system-wide preferences (Scored)
auditStep="5.9 Require an administrator password to access system-wide preferences (Scored)"
auditCmd=`security authorizationdb read system.preferences 2> /dev/null | grep -A1 shared | grep -E '(false)'`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.10 Disable ability to login to another user's active and locked session (Scored)
auditStep="5.10 Disable ability to login to another user's active and locked session (Scored)"
auditCmd=`grep -i "group=admin,wheel fail_safe" /Private/etc/pam.d/screensaver`
audit_WithNoOutput "$auditStep" "$auditCmd"
##########################
#5.11 Complex passwords must contain an Alphabetic Character (Scored)
auditStep="5.11 Complex passwords must contain an Alphabetic Character (Scored)"
auditCmd=`pwpolicy -getglobalpolicy | tr " " "\n" | grep -i "requiresAlpha=1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.12 Complex passwords must contain a Numeric Character (Scored)
auditStep="5.12 Complex passwords must contain a Numeric Character (Scored)"
auditCmd=`pwpolicy -getglobalpolicy | tr " " "\n" | grep -i "requiresNumeric=1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.13 Complex passwords must contain a Symbolic Character (Scored)
auditStep="5.13 Complex passwords must contain a Symbolic Character (Scored)"
auditCmd=`pwpolicy -getglobalpolicy | tr " " "\n" | grep -i "requiresSymbol=1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.14 Set a minimum password length (Scored)
auditStep="5.14 Set a minimum password length (Scored)"
auditCmd=`pwpolicy -getglobalpolicy | tr " " "\n" | grep -i "minChars=12"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.15 Configure account lockout threshold (Scored)
auditStep="5.15 Configure account lockout threshold (Scored)"
auditCmd=`pwpolicy -getglobalpolicy | tr " " "\n" | grep -i "maxFailedLoginAttempts=5"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.16 Create a custom message for the Login Screen (Scored)
auditStep="5.16 Create a custom message for the Login Screen (Scored)"
#auditCmd=`defaults read /Library/Preferences/com.apple.loginwindow.plist LoginwindowText`
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.17 Create a Login window banner (Scored)
auditStep="5.17 Create a Login window banner (Scored)"
#auditCmd=`grep -i Authorized /Library/Security/PolicyBanner.txt`
authdCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.18 Do not enter a password-related hint (Not Scored)
auditStep="5.18 Do not enter a password-related hint (Not Scored) - controlled by AD"
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.19 Disable Fast User Switching (Not Scored)
auditStep="5.19 Disable Fast User Switching (Not Scored)"
auditCmd=`defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled | grep "0"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#5.20 Secure individual keychain items (Not Scored)
auditStep="5.20 Secure individual keychain items (Not Scored)"
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
##########################
#5.21 Create specialized keychains for different purposes (Not Scored)
auditStep="5.21 Create specialized keychains for different purposes (Not Scored)"
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"
####################################################
#6 User Accounts and Environment
#6.1 Accounts Preferences Action Items
#6.1.1 Display login window as name and password (Scored)
auditStep="6.1.1 Display login window as name and password (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME |grep -i "1"`
audit_WithOutput "$auditStep" "$auditCmd"
#6.1.2 Disable Show password hints (Scored)
auditStep="6.1.2 Disable Show password hints (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.loginwindow RetriesUntilHint | grep -i "0"`
audit_WithOutput "$auditStep" "$auditCmd"
#6.1.3 Disable guest account login (Scored)
auditStep="6.1.3 Disable guest account login (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.loginwindow.plist GuestEnabled | grep "0"`
audit_WithOutput "$auditStep" "$auditCmd"
#6.1.4 Disable Allow guests to connect to shared folders (Scored)
auditStep="6.1.4 Disable Allow guests to connect to shared folders (Scored)"
auditCmd=`defaults read /Library/Preferences/com.apple.AppleFileServer | grep -E "guestAccess\s+=\s+0"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#6.2 Turn on filename extensions (Scored)
auditStep="6.2 Turn on filename extensions (Scored)"
auditCmd=`defaults read NSGlobalDomain AppleShowAllExtensions | grep "1"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#6.3 Disable the automatic run of safe files in Safari (Scored)
auditStep="6.3 Disable the automatic run of safe files in Safari (Scored)"
auditCmd=`defaults read com.apple.Safari AutoOpenSafeDownloads | grep "0"`
audit_WithOutput "$auditStep" "$auditCmd"
##########################
#6.4 Use parental controls for systems that are not centrally managed (Not Scored)
auditStep="6.4 Use parental controls for systems that are not centrally managed (Not Scored)"
auditCmd=``
audit_Exception "$auditStep" "$auditCmd"

########################################## For Future Desktop / Laptop audits #################################################

#7 Appendix: Additional Considerations
#7.1 Wireless Adapters on Mobile Clients (Not Scored)
#auditStep="7.1 Wireless Adapters on Mobile Clients (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.2 iSight Camera Privacy and Confidentiality Concerns (Not Scored)
#auditStep="7.2 iSight Camera Privacy and Confidentiality Concerns (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.3 Computer Name Considerations (Not Scored)
#auditStep="7.3 Computer Name Considerations (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.4 Software Inventory Considerations (Not Scored)
#auditStep="7.4 Software Inventory Considerations (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.5 Firewall Consideration (Not Scored)
#auditStep="7.5 Firewall Consideration (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.6 Automatic Actions for Optical Media (Not Scored)
#auditStep="7.6 Automatic Actions for Optical Media (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.7 App Store Automatically download apps purchased on other Macs Considerations (Not Scored)
#auditStep="7.7 App Store Automatically download apps purchased on other Macs Considerations (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.8 Extensible Firmware Interface (EFI) password (Not Scored)
#auditStep="7.8 Extensible Firmware Interface (EFI) password (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"
#7.9 Apple ID password reset (Not Scored)
#auditStep="7.9 Apple ID password reset (Not Scored)"
#auditCmd=`echo test`
#audit_Exception "$auditStep" "$auditCmd"

############################################ From CentOS 6 #############################################
#Security 1.1 - join system to domain
auditStep="Security.1.1 system joined to domain"
#auditCmd=`dsconfigad -show | grep "domain.local"`
auditCmd=` | grep -i "domain.local"`
audit_WithOutput "$auditStep" "$auditCmd"
#Security 1.2 - install Casper
auditStep="Security.1.2 Casper installed"
auditCmd=`ls "/Applications/Self Service.app/Contents/MacOS/Self Service"`
audit_WithOutput "$auditStep" "$auditCmd"
#Security 1.3 - modify hosts.allow
auditStep="Security.1.3 modify hosts.allow"
auditCmd=`grep -iE "ALL: 10.0.0.0/255.0.0.0|ALL: 172.16.0.0/255.240.0.0|ALL: 192.168.0.0/255.255.0.0" /etc/hosts.allow`
audit_WithOutput "$auditStep" "$auditCmd"
#Security 1.4 - modify hosts.deny
auditStep="Security.1.4 modify hosts.deny"
auditCmd=`grep -i "ALL: ALL" /etc/hosts.deny`
audit_WithOutput "$auditStep" "$auditCmd"
#Security 1.5 - configure ssh
auditStep="Security.1.5 ssh config issue"
auditCmd=`grep -iE "PermitRootLogin no|AllowGroups admin osxadmins|Protocol 2|PermitEmptyPasswords no" /etc/sshd_config`
audit_WithOutput "$auditStep" "$auditCmd"
#this will find any passwordless sudo settings
auditStep="Security.1.6 No passwordless sudo"
auditCmd=`grep "NOPASSWD" /etc/sudoers | grep -v '#'`
audit_WithNoOutput "$auditStep" "$auditCmd"
# #####################################################################
# # Security.2 llow auditd to get the calling user's uid correctly when calling sudo or su
# #This will allow auditd to get the calling user's uid correctly when calling sudo or su.
# auditStep="Security.2.1 pam_loginuid.so in /Private/etc/pam.d/login"
# auditCmd=`grep -E "session\s+required\s+pam_loginuid.so" /Private/Private/etc/pam.d/login`
# audit_WithOutput "$auditStep" "$auditCmd"
# #This will allow auditd to get the calling user's uid correctly when calling sudo or su.
# auditStep="Security.2.2 pam_loginuid.so in /Private/etc/pam.d/gdm"
# auditCmd=`grep -E "session\s+required\s+pam_loginuid.so" /Private/etc/pam.d/gdm`
# audit_WithOutput "$auditStep" "$auditCmd"
# #This will allow auditd to get the calling user's uid correctly when calling sudo or su.
# auditStep="Security.2.3 pam_loginuid.so in /Private/etc/pam.d/sshd"
# auditCmd=`grep -E "session\s+required\s+pam_loginuid.so" /Private/etc/pam.d/sshd`
# audit_WithOutput "$auditStep" "$auditCmd"
# #####################################################################
# # Security.3 bashrc configuration
# userCounter=1
# for user in `ls /Users`; do
# 	if [[ "$user" != ".localized" ]]; then
# 		#This will check if each user's bashrc is configured correctly
# 		auditStep="Security.3.$userCounter reconfigure bashrc for $user"
# 		auditCmd=`egrep "export HISTCONTROL=ignoredups:erasedups|export HISTSIZE=100000|export HISTFILESIZE=100000|export HISTTIMEFORMAT=\"%m/%d/%y %T \"|shopt -s histappend|export PROMPT_COMMAND=" /Users/$user/.bashrc`
# 		audit_WithOutput "$auditStep" "$auditCmd"
# 	fi
# 	#increment Counter
# 	userCounter=$((userCounter+1))
# done
# #reconfigure /root/bashrc
# userCounter=$((userCounter+1))
# auditStep="Security.3.$userCounter reconfigure bashrc for Root"
# auditCmd=`egrep "export HISTCONTROL=ignoredups:erasedups|export HISTSIZE=100000|export HISTFILESIZE=100000|export HISTTIMEFORMAT=\"%m/%d/%y %T \"|shopt -s histappend|export PROMPT_COMMAND=" /Users/$user/.bashrc`
# audit_WithOutput "$auditStep" "$auditCmd"
# #reconfigure /etc/skel/.bashrc
# userCounter=$((userCounter+1))
# auditStep="Security.3.$userCounter reconfigure bashrc for skel"
# auditCmd=`egrep "export HISTCONTROL=ignoredups:erasedups|export HISTSIZE=100000|export HISTFILESIZE=100000|export HISTTIMEFORMAT=\"%m/%d/%y %T \"|shopt -s histappend|export PROMPT_COMMAND=" /Users/$user/.bashrc`
# audit_WithOutput "$auditStep" "$auditCmd"
#####################################################################
echo "-------------------complete---------------"
