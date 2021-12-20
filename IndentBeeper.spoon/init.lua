IndentBeeper={}
IndentBeeper.name="Indent Beeper"
IndentBeeper.version=1.1
IndentBeeper.author="Pitermach, Talon"
IndentBeeper.license="MIT"
local spaces=2 --the number of spaces for 1 level of indent.
local tabs=1 --same thing
local ax = require("hs.axuielement")
local inspect = hs.inspect
local lastIndent = 0
local lastLineNum = 0
local sounds = {}
function IndentBeeper.init()
    
    
    
    for i = 0, 32 do
        sounds[i] = hs.sound.getByFile(hs.spoons.resourcePath("indentSounds/" .. tostring(i) .. ".mp3"))
    end
    
end --init function

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
        local tabIndent=0
        startIndex, endIndex=str:find("(%s+)", 1)
        if startIndex==1 then
            --print(str:sub(startIndex, endIndex))
            spaceIndent=math.floor(endIndex/spaces)
        else
            spaceIndent=0
        end --if it's a string
        
        startIndex, endIndex=str:find("(\t+)", 1)
        if startIndex==1 then
            tabIndent=math.floor(endIndex/tabs)
        else
            tabIndent=0
        end --if it's a string
        
        return spaceIndent+tabIndent
        
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
                if currentIndent<=32 then
                    sounds[currentIndent]:play()
                else --32 is the highest sound we have
                    sounds[32]:play()
                end --sound number check
                
                lastIndent = currentIndent
            end
        end
    end -- if the focused element isn't nil
    
end -- check indent function


checkTimer = hs.timer.doEvery(0.1, checkIndent)
function IndentBeeper.start()
    checkTimer:start()
end --start function

function IndentBeeper.stop()
    checkTimer:stop()
end --start function

return IndentBeeper