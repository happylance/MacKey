# MacKey

MacKey is an iOS app which can be used to unlock Mac using touch ID and ssh connection.

## Prerequisites
1. This app will only work on an iOS device with Touch ID enabled.
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

  
