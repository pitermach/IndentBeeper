IndentBeeper = {}
IndentBeeper.name = "Indent Beeper"
IndentBeeper.version = "2.0"
IndentBeeper.author = "Pitermach, Talon"
IndentBeeper.license = "MIT"

-- Settings; change them before calling start().

-- Spaces per step up in pitch. 1 gives every number of spaces its own tone;
-- set it to your indent size (2, 4...) for one tone per level instead.
IndentBeeper.spacesPerStep = 1
-- How many spaces a tab counts as.
IndentBeeper.tabWidth = 4
-- The tone for no indentation, how many steps make an octave and how many
-- octaves the tones span. By default, as NVDA: A3 (220 Hz) up to A6 (1760 Hz)
-- in quarter tones (24 to the octave), so 72 spaces. 12 gives semitones: a
-- bigger step per space, up to 36 spaces. Beyond the highest tone the scale
-- starts again from the lowest, with longer tones each time round.
IndentBeeper.lowestFrequency = 220
IndentBeeper.stepsPerOctave = 24
IndentBeeper.octaves = 3
-- Length (seconds) and loudness (0 to 1) of each tone; NVDA's defaults.
IndentBeeper.toneLength = 0.04
IndentBeeper.volume = 0.21
-- How much longer (seconds) the tones get each time the scale starts again.
IndentBeeper.lapLength = 0.08

local ax = require("hs.axuielement")

local tones = {}
local lastIndent = 0
local observer
local appWatcher
local pendingCheck

-- Hammerspoon can only play sound files, so the tones are calculated and
-- written as short WAV files in a temporary folder when IndentBeeper starts.
-- The tone is modelled on NVDA's beeps: a sine wave doubled and clipped, which
-- flattens its peaks into a brighter tone, lasting a whole number of cycles
-- so it starts and ends at zero without clicking. (NVDA rounds the cycle
-- length down to whole samples, so its higher tones drift and end mid-wave;
-- this works the length out from the exact frequency instead.)
local function writeTone(path, frequency, length)
    local rate = 44100
    local cycles = math.ceil(length * frequency)
    local count = math.floor(cycles * rate / frequency + 0.5)
    local step = 2 * math.pi * frequency / rate
    local samples = {}
    for i = 0, count do -- includes the final zero
        local value = math.max(-1, math.min(1, math.sin(i * step) * 2)) * IndentBeeper.volume
        samples[#samples + 1] = string.pack("<i2", math.floor(value * 32767))
    end
    local data = table.concat(samples)
    local file = io.open(path, "wb")
    file:write("RIFF", string.pack("<I4", 36 + #data), "WAVE")
    file:write("fmt ", string.pack("<I4I2I2I4I4I2I2", 16, 1, 1, rate, rate * 2, 2, 16))
    file:write("data", string.pack("<I4", #data), data)
    file:close()
end

local folder = hs.fs.temporaryDirectory() .. "IndentBeeper"

local function stepsPerLap()
    return IndentBeeper.stepsPerOctave * IndentBeeper.octaves + 1
end

-- The tone for a step of the scale on a given lap (0 the first time through),
-- made the first time it's needed.
local function tone(step, lap)
    local key = lap * stepsPerLap() + step
    if not tones[key] then
        local frequency = IndentBeeper.lowestFrequency * 2 ^ (step / IndentBeeper.stepsPerOctave)
        local path = string.format("%s/%d-%d.wav", folder, lap, step)
        writeTone(path, frequency, IndentBeeper.toneLength + lap * IndentBeeper.lapLength)
        tones[key] = hs.sound.getByFile(path)
    end
    return tones[key]
end

local function makeTones()
    hs.fs.mkdir(folder)
    for file in hs.fs.dir(folder) do
        if file:match("%.wav$") then
            os.remove(folder .. "/" .. file)
        end
    end
    tones = {}
    for step = 0, stepsPerLap() - 1 do
        tone(step, 0)
    end
end

local function currentLine(element)
    local lineNum = element.AXInsertionPointLineNumber
    if lineNum == nil or element.AXRangeForLineWithParameter == nil or element.AXStringForRangeWithParameter == nil then
        return nil
    end
    local range = element:AXRangeForLineWithParameter(lineNum)
    return range and element:AXStringForRangeWithParameter(range)
end

-- Columns of indentation: each leading space is one, each leading tab
-- tabWidth. Stops at the first other character, so a line break isn't counted.
local function indentColumns(line)
    local columns = 0
    for i = 1, #(line or "") do
        local character = line:sub(i, i)
        if character == " " then
            columns = columns + 1
        elseif character == "\t" then
            columns = columns + IndentBeeper.tabWidth
        else
            break
        end
    end
    return columns
end

-- Plays the tone for a number of columns of indentation.
local function playColumns(columns)
    local step = math.floor(columns / IndentBeeper.spacesPerStep)
    -- Past the highest tone, start the scale again with longer tones.
    local sound = tone(step % stepsPerLap(), step // stepsPerLap())
    sound:stop()
    sound:play()
    return step
end

-- Play the tone for a given number of spaces, e.g. to hear the scale.
function IndentBeeper.playIndent(spaces)
    playColumns(spaces)
end

local function checkIndent()
    local element = ax.systemWideElement():attributeValue("AXFocusedUIElement")
    if element == nil then
        return
    end
    local role = element:attributeValue("AXRole")
    if role ~= "AXTextField" and role ~= "AXTextArea" then
        return
    end
    local line = currentLine(element)
    if line == nil then
        return
    end
    local columns = indentColumns(line)
    local step = math.floor(columns / IndentBeeper.spacesPerStep)
    if step == lastIndent then
        return
    end
    lastIndent = step
    playColumns(columns)
end

local function scheduleCheck()
    if pendingCheck then
        pendingCheck:stop()
    end
    -- Notifications come in bursts; check once, just after.
    pendingCheck = hs.timer.doAfter(0.03, checkIndent)
end

-- Instead of checking several times a second, ask the frontmost app to say
-- when its text cursor moves or its focus changes, and check only then.
local function observe(app)
    if observer then
        observer:stop()
        observer = nil
    end
    if app == nil then
        return
    end
    local ok, newObserver = pcall(ax.observer.new, app:pid())
    if not ok or newObserver == nil then
        return
    end
    local element = ax.applicationElement(app)
    pcall(function()
        newObserver:addWatcher(element, "AXSelectedTextChanged")
        newObserver:addWatcher(element, "AXFocusedUIElementChanged")
    end)
    newObserver:callback(scheduleCheck)
    newObserver:start()
    observer = newObserver
    scheduleCheck()
end

function IndentBeeper.init() end

function IndentBeeper.start()
    makeTones()
    appWatcher = hs.application.watcher.new(function(_, event, app)
        if event == hs.application.watcher.activated then
            observe(app)
        end
    end)
    appWatcher:start()
    observe(hs.application.frontmostApplication())
end

function IndentBeeper.stop()
    if appWatcher then
        appWatcher:stop()
        appWatcher = nil
    end
    observe(nil)
end

return IndentBeeper
