# MacKey

MacKey is an iOS app which can be used to unlock Mac using SSH connection.

## Prerequisites
1. This app will only work when iOS device and Mac are within the same WiFi network.
2. On Mac, `Remote Login` needs to be enabled in `System Preferences` -> `Sharing`.

## Recommended way to lock screen on Mac
1. Open `System Preferences` -> `Security & Privacy`. Check `Require password immediately after sleep or screen saver begins`.
2. Use one of the following methods to turn off the screen.

  A. Close the lid.
  
  B. Hold down the Command+Option+Eject keys together.

  C. Hold down the Command+Option+Power keys together.

  D. Open `Automator` app. Choose `Application`. Type `Script` in the search box. Double click `Run Shell Script`. 
  Replace `cat` with `pmset displaysleepnow`. Use `Command+S` to save the app as an application. 
  Then drag the saved applicaiton to Dock. Click on the new application in Dock will make the display sleep.

## Security
1. Host address, user name and password are saved in iOS keychain.
2. Every unlock action is protected by a related touch ID authentication if `Require Touch ID` option is enabled.
3. Communications between this app and Mac are protected by SSH connection using NMSSH framework.
4. It is recommended to delete all the hosts manually before deleting this app.

## [Privacy Policy](https://github.com/happylance/MacKey/blob/master/Privacy-Policy.md)
