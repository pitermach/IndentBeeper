synth = hs.speech.new()
local ax = require("hs.axuielement")
local inspect = hs.inspect
local lastIndent = 0
local lastLineNum = 0
local sounds = {}

function loadSounds()
    for i = 0, 32 do
        sounds[i] = hs.sound.getByFile("indentSounds/" .. tostring(i) .. ".mp3")
    end
    sounds[1]:play()
end

function getCurrentLineNum(element)
    local role = element:attributeValue("AXRole")
    if role == "AXTextField" or role == "AXTextArea" then
        lineNum = element.AXInsertionPointLineNumber
        return lineNum
    else
        return nil
        
    end
end

function getCurrentLine(element)
    local role = element:attributeValue("AXRole")
    if role == "AXTextField" or role == "AXTextArea" then
        lineNum = getCurrentLineNum(element)
        if element.AXRangeForLineWithParameter ~=nil then
            local lineRange = element:AXRangeForLineWithParameter(lineNum)
            local content = element:AXStringForRangeWithParameter(lineRange)
            return content or nil
        else --no range parameter
            return nil
        end
        
    end
end

function getIndentLevel(str)
    if str == nil then
        return 0
    else
        
        local spaceIndent = 0
        for i in str:gmatch("%s%s") do
            spaceIndent = spaceIndent + 1
        end
        local tabIndent = 0
        for i in str:gmatch("\t") do
            tabIndent = tabIndent + 1
        end
        if spaceIndent > tabIndent then
            return spaceIndent
        else
            return tabIndent
        end
    end -- if the string is nil or not
end -- function
function checkIndent()
    local systemElement = ax.systemWideElement()
    local element = systemElement:attributeValue("AXFocusedUIElement")
    if element ~= nil then
        local role = element:attributeValue("AXRole")
        
        if role == "AXTextField" or role == "AXTextArea" then
            lastLineNum = getCurrentLineNum(element)
            
            currentIndent = getIndentLevel(getCurrentLine(element))
            
            if currentIndent ~= lastIndent then
                sounds[currentIndent]:play()
                
                lastIndent = currentIndent
            end
        end
    end -- if the focused element isn't nil
    
end -- check indent function

loadSounds()
checkTimer = hs.timer.doEvery(0.1, checkIndent)
checkTimer:start()
