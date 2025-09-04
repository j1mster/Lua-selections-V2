--# VS Code Tags #--

---@diagnostic disable: undefined-field


--# Variables #--

local messages              = {}

local string                = require("string")

local padding               = 17
local stdout                = _G.process.stdout.handle

local getOptionsString      = nil 

local activeInputObject     = nil


--# Local Functions #--

local function refresh(_)
    local newStr = ""
    local inputObject = activeInputObject

    do
        local pinned,unpinned={},{}
        for _, msg in pairs(messages) do
            if msg.pinned then 
                table.insert(pinned, msg)
            else
                table.insert(unpinned, msg)
            end
        end
        table.sort(pinned, function(a, b)
            return a.creationTime > b.creationTime
        end) table.sort(unpinned, function(a, b)
            return a.creationTime > b.creationTime
        end)
        for _, msg in pairs(unpinned) do
            newStr = newStr .. "\n"
        end
        for _, msg in pairs(pinned) do
            newStr = newStr .. "\n"
        end
    end

    if inputObject and inputObject.active then 
        local selected = 0 

        for rowIndex, row in pairs(inputObject.options) do
            for valueIndex, value in pairs(row) do
                selected = selected + ((value.__isSelected and 1) or 0)
            end
        end


        newStr = newStr .. string.format(
            "+ %s%s%s\n%s\n\nUse arrow keys to navigate.",
            inputObject.name, -- name 
            ((inputObject.maxSelection > 1 and (not inputObject.maxIsAll) and string.format(" - select up to %d", inputObject.maxSelection)) or "+"), -- selection allowed amount
            ((inputObject.maxSelection > 1 and string.format("(%d selected)", inputObject.maxSelection)) or ""),
            ("\n" .. getOptionsString(inputObject))
       )
    end 

    os.execute("cls")
    stdout:write(newStr)
end
local function clear(_)
    messages = {}
    refresh()
end 
local function write(_, msg)
    if type(msg) == "string" then 
        msg = _G.lua_selections.newMessage(msg)
    end 

    table.insert(messages, msg)
    return msg
end
local function warn(_, message)
    local front = "[ WARNING ]"
    write(string.color(front, "yellow").. string.rep(" ", padding - #front) .. message)
end
local function err(_, message)
    local front = "[ ERROR ]"
    write(string.color(front, "RED").. string.rep(" ", padding - #front) .. message)
end


--# Finalization #--

return {
    messages = messages,

    refresh = refresh,
    clear = clear,
    write = write,
    warn = warn,
    error = err,

    __local = {
        setGetOptionsStringFunction = function(f)
            getOptionsString = f
        end,
        setActiveInputObject = function(inputObject)
            activeInputObject = inputObject
        end
    }
}