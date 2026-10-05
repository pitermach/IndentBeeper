IndentBeeper is a Hammerspoon spoon which is designed to fill in one of the larger gaps between Mac and Windows programming productivity with a screen reader. Ask a blind developer why they prefer to code on Windows, and chances are one of the main reasons you'll hear most often is that VoiceOver has no way to announce indentation level, something which can be very important especially when dealing with languages that require it like Python. IndentBeeper aims to solve this gap by indicating the indent of the line under the cursor with a sound, with its pitch indicating how indented the line is.

## Installation

First, download and install Hammerspoon. You can do so either [from their Github](https://github.com/Hammerspoon/hammerspoon/releases/latest), or if you have it installed, through homebrew simply by running "brew install Hammerspoon" in the terminal. Once you have it installed, run it, and follow the prompts to grant accessibility permissions (I also choose to hide the app from the dock here so it stays out of your command-tab switcher)

Once Hammerspoon is installed and configured, navigate into the folder where you cloned this repository with Finder or another file manager, and open "IndentBeeper.spoon" which should cause Hammerspoon to install it into the right place. Finally, from the Hammerspoon menu extra select the open configuration option which should open your default text editor with your init.lua file. To make IndentBeeper work and do its thing, simply add the following 2 lines:
```lua
hs.loadSpoon("IndentBeeper")
spoon.IndentBeeper:start()
```

Save the file, return to the Hammerspoon menu extra but this time click the reload configuration option for your new changes to take effect. And this should be all there is to it!

## How it sounds

Each space of indentation raises the pitch by a quarter tone, starting from A3 (220 Hz) for no indentation, so 2 and 3 spaces, or 4 and 5, sound different. A tab counts as 4 spaces. That covers three octaves, up to A6 (1760 Hz) at 72 spaces; beyond that the scale starts again from A3, with longer tones each time round, so very deep indentation can't be mistaken for shallow.

The tones are generated rather than played from sound files, and are modelled on [NVDA](https://github.com/nvaccess/nvda)'s beeps and its indentation tones: a sine wave doubled and clipped, for a brighter tone, 40 milliseconds long, with NVDA's pitches. IndentBeeper doesn't poll: it checks the indentation only when the front app reports its text cursor moving or its focus changing.

## Settings

Set these in your `init.lua` before `spoon.IndentBeeper:start()`, e.g. `spoon.IndentBeeper.stepsPerOctave = 12`.

* `spacesPerStep` (default 1): spaces per step up in pitch. Set it to your indent size (2, 4...) for one tone per level instead.
* `tabWidth` (default 4): how many spaces a tab counts as.
* `stepsPerOctave` (default 24, quarter tones as in NVDA): 12 gives semitones, a bigger step per space, up to 36 spaces.
* `lowestFrequency` (default 220) and `octaves` (default 3): where the scale starts and how far it goes.
* `toneLength` (default 0.04 seconds), `volume` (default 0.21, from 0 to 1) and `lapLength` (default 0.08 seconds, how much longer the tones get each time the scale starts again).

## Todo

There's one more thing I'd like to do that was floated around by friends as a suggestion:

- [ ] Add an ability to make an include/exclude list of applications where the script should function

If this sounds like something you'd really want or if you have other cool ideas on how this could be expanded, pull requests and other feature suggestions are welcome!
