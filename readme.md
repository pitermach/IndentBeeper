IndentBeeper is a Hammerspoon spoon which is designed to fill in one of the larger gaps between Mac and Windows programming productivity with a screen reader. Ask a blind developer why they prefer to code on Windows, and chances are one of the main reasons you'll hear most often is that VoiceOver has no way to announce indentation level, something which can be very important especially when dealing with languages that require it like Python. IndentBeeper aims to solve this gap by indicating the indent of the line under the cursor with a sound, with its pitch indicating how indented the line is.

## Installation

First, download and install Hammerspoon. You can do so either [from their Github](https://github.com/Hammerspoon/hammerspoon/releases/latest), or if you have it installed, through homebrew simply by running "brew install Hammerspoon" in the terminal. Once you have it installed, run it, and follow the prompts to grant accessibility permissions (I also choose to hide the app from the dock here so it stays out of your command-tab switcher)

Once Hammerspoon is installed and configured, navigate into the folder where you cloned this repository with Finder or another file manager, and open "IndentBeeper.spoon" which should cause Hammerspoon to install it into the right place. Finally, from the Hammerspoon menu extra select the open configuration option which should open your default text editor with your init.lua file. To make IndentBeeper work and do its thing, simply add the following 2 lines:
```lua
hs.loadSpoon("IndentBeeper")
spoon.IndentBeeper:start()
```

Save the file, return to the Hammerspoon menu extra but this time click the reload configuration option for your new changes to take effect. And this should be all there is to it!

## Todo

While IndentBeeper already does what it's supposed to, there's a couple of things 