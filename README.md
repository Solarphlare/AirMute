# AirMute
Mute your mic in Discord on Mac with your AirPods.

## What exactly is this?
As of writing, Discord doesn't support muting the microphone using your AirPods on macOS. This app aims to allow you to do so by registering for mute/unmute notifications from your AirPods, and then instructing Discord to mute or unmute your mic over RPC. Muting or unmuting your mic in Discord will also notify the AirPods that they have been unmuted or muted.

Here's a video of it in action:

https://gist.github.com/user-attachments/assets/f0c74cca-f60f-4415-9f00-cb6a0c2397ab

## Features
- Mute your Discord mic with your AirPods!
- A simple, clean, and minimal UI that stays out of your way whilst also providing helpful information on the status of the app.
- A fully notarized app! No need to override Gatekeeper just to run the app. (Available from the [releases](https://github.com/CominAtYou/AirMute/releases/latest) page)

## Requirements
- A Mac (Intel or Apple Silicon) with macOS 14.0 or higher.
- A pair of AirPods Pro, AirPods 3 or newer, or AirPods Max.
- Have the Discord app installed on your Mac. This app doesn't work with the browser version of Discord.

## Setup
1. First, download the disk image of the latest version of the app from the [releases](https://github.com/CominAtYou/AirMute/releases/latest) page. Open the disk image and drag the app to your Applications folder.

    Or you can install AirMute via Homebrew:
    ```
    brew tap solarphlare/tap
    brew install --cask airmute
    ```
2. Head to the [Discord Developer Portal](https://discord.com/developers/applications) and create a new application.
3. Click OAuth2 in the sidebar. Copy your client ID and client secret.
4. Add a redirect URI to `http://localhost`.
5. Launch the app, and click its menu bar icon (it looks like a person with waves) and select "Settings".
    - If you don't see the settings wndow, it might be behind other windows.
6. Paste your client ID and secret into this window, and then close the window.
7. Quit the app by clicking its menu bar icon and selecting "Quit".
8. Open Discord if it isn't already open.
9. Open the app again.
10. Discord will bring up a dialog asking you to authorize AirMute to modify your voice settings. Click "Authorize".
    - This permission is necessary for AirMute to be able to mute and unmute you.
11. If everything worked correctly, clicking the menu bar icon again should yield a line that says `Inactive - Not in Voice` or `Active - In Voice`.

## How does this work?
The Discord allows any application to interface and issue commands to it (with your approval, of course) over RPC. One of the things that RPC allows for is controlling whether or not your mic is muted or not, meaning that the app is able to instruct Discord to toggle the microphone whenever the AirPods are clicked.

### A more technical explanation, please?
Basically:
- [`AVAudioApplication.setInputMuteStateChangeHandler(_:)`](https://developer.apple.com/documentation/avfaudio/avaudioapplication/4191602-setinputmutestatechangehandler) lets you register a callback for when the AirPods have been clicked to mute.
- Discord exposes a Unix socket in /var/tmp that allows for external processes to control and recieve information about some aspects of the client over [RPC](https://discord.com/developers/docs/topics/rpc).
- Using these two, it's possible to get notifications for when the AirPods are muted, as well as when the mic has been muted within the Discord client itself, and dispatch the information to both the AirPods or Discord to keep things in sync.

## Questions? Answers!
### How do I see the current status of the app?
Clicking the app's menu bar icon will yield a menu that'll tell you if the app is active or not (the app is only active when you're in voice), and will also let you know why the app is inactive, or of any errors that might have occured.

### What does "Click to Undeafen" in the app's settings do?
Enabling this setting will let you undeafen yourself by clicking the stem or Digital Crown on your AirPods whilst deafened. Turning it off will prevent you from being undeafened when clicking the stem or Digital Crown, but it won't unmute you either.

### Why do I sometimes have to re-authorize the app in Discord?
Discord requires apps that haven't been approved to re-request authorization from you every seven days. There's nothing that can be done about this, unfortunately. Sorry!

### The settings window doesn't show up.
The settings window sometimes likes to show up behind other windows. Minimize all of the windows you've got open to locate it, or use Mission Control to find it.

## Something not working?
### Check the status menu first!
Click the app's menu bar icon to see if any erorrs are being reported. That should give you a pointer as to what might be wrong.
### Maybe there's an update!
Check the [releases](https://github.com/CominAtYou/AirMute/releases/latest) for a newer version of the app. It might have fixed the issue you're experiencing.
### No luck?
Open an issue, and let me know what's up. I'll take a look and do my best to track down what might be going awry.

## Credits
- Much of the RPC code was sourced from [aeddi/DiscordRPC](https://github.com/aeddi/DiscordRPC) with some modifications to handle the full authentication lifecycle and support the handling of voice state changes.
- `AudioInputController` was sourced from https://stackoverflow.com/q/78386629.

