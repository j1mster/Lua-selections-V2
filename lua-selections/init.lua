--# VS Code Tags #--

---@diagnostic disable: undefined-field


--# Variables #--

local module                = {}

local uv                    = require('uv')

local stdout                = _G.process.stdout.handle 
local stdin                 = uv.new_tty(0, true)

local selectionPosition     = {X=1,Y=1}
local activeInputObject     = nil

local number                = require("number")
local message               = require("message")
local string                = require("string")

local output                = require("output")


local config                = {cursorColor="orange",selectedValueColor="green",submitButtonColor="pink",xPadding = 5,hardExit=true}


--# Local Functions #--

local function getSelected(inputObject)
    if inputObject.maxAllowedOptions > 1 then
        local selected = {}

        for rowIndex, row in ipairs(inputObject.options) do
            for valueIndex, value in ipairs(row) do
                if value.__isSelected then 
                    selected[value.value] = true 
                end
            end
        end

        return selected, false
    else
        local optionY = inputObject.options[selectionPosition.Y]
        local optionX = optionY and optionY[selectionPosition.X]

        return optionX, selectionPosition.Y
    end
end
local function getLongestXStringLength(inputObject)
    local longest = 0

    for _, row in ipairs(inputObject.options) do
        for _, value in ipairs(row) do
            local valueName = string.strip(value.name)
            local len = #valueName

            longest = (len > longest and len) or longest
        end
    end

    return longest
end
local function getOptionsString(inputObject)
    local longestNameLength = getLongestXStringLength(inputObject)
    local active = inputObject.active

    local str = ""

    for rowIndex, rowTable in ipairs(inputObject.options) do
        local rowString = ""

        for valueIndex, value in ipairs(rowTable) do
            local optionName = value.name
            if active then
                if rowIndex == selectionPosition.Y and valueIndex == selectionPosition.X then
                    optionName = string.color(optionName, config.cursorColor)
                elseif value.__identifyAsSubmit then
                    optionName = string.color(optionName, config.submitButtonColor)
                elseif value.__isSelected then
                    optionName = string.color(optionName, config.selectedValueColor)
                end
            end
            local repititionLength = (longestNameLength + config.xPadding) - #string.strip(value.name)
            rowString = rowString .. optionName .. string.rep(" ", repititionLength)
        end
        str = str .. rowString .. "\n"
    end

    return str
end
local function closePrompt(inputObject)
    uv.read_stop(stdin)
    uv.tty_set_mode(stdin, 0)

    inputObject = inputObject or activeInputObject

    if inputObject and inputObject.active then 
        inputObject.active = false 

        local callback = inputObject.callback
        local options = getOptionsString(inputObject)

        local returnValue, returnRow = getSelected(inputObject)
        inputObject.final = returnValue

        local msg = string.format("%s\n%s\nUser>%s", inputObject.name, options, (returnRow and returnValue) or ("<multiple values selected>"))
        table.insert(output.messages, message.new(msg))

        selectionPosition = {X=1,Y=1}

        activeInputObject = nil 
        output.__local.setActiveInputObject(activeInputObject)

        callback(returnValue, returnRow) -- table for multiple options allowed + returnRow is nil, value for only one option allowed + returnRow is the index of the row
    end

    output:refresh()
end

--input helpers 
local function submit(inputObject)
    if inputObject.active then
        if inputObject.maxAllowedOptions > 1 then
            local optionsY = inputObject.options[selectionPosition.Y]
            local optionX = optionsY and optionsY[selectionPosition.X]

            if optionX then

                if optionX.__identifyAsSubmit then
                    closePrompt(inputObject)
                    return
                else
                    local options = getSelected(inputObject)
                    local count = number.countTable(options)

                    if count >= inputObject.maxAllowedOptions then
                        output:warn(string.format("YOU CAN ONLY SELECT %s VALUE(S)", tostring(inputObject.maxAllowedOptions)))
                        return
                    end 
                end
                optionX.__isSelected = not optionX.__isSelected
            end
        else
            closePrompt(inputObject)
        end
    end

    output:refresh()
end
local function exit(self)
    output:write("Exiting prompt...")

    if activeInputObject then 
        activeInputObject.callback(nil, nil) 
        activeInputObject = nil
        output.__local.setActiveInputObject(nil)
        output:refresh()
    end 

    uv.read_stop(stdin)
    uv.tty_set_mode(stdin, 0)
    uv.close(stdin)
    if config.hardExit then 
        uv.stop()
    end 
end
local function onNewInput(key) 
    local prompt = activeInputObject
    local promptActive = prompt and prompt.active 
    local newX, newY = nil, nil 
    local oldX, oldY = selectionPosition.X, selectionPosition.Y 

    if key == "\003" or key == "♥" then 
        exit()
    end 
    if prompt and promptActive then 
        if (key=="\n" or key=="\r") then 
            submit(prompt)
        elseif tonumber(key) then 
            newY = number.clamp(tonumber(key), 1, #prompt.options) 
        else 
            local additiveY = ((key:lower()=="up" or key=="\027[A") and -1) or ((key:lower()=="down" or key=="\027[B") and 1) or 0 
            local additiveX = ((key:lower()=="left" or key=="\027[D") and -1) or ((key:lower()=="right" or key=="\027[C") and 1) or 0 

            newY = number.clamp(oldY + additiveY, 1, #prompt.options) 
            newX = number.clamp(oldX + additiveX, 1, #prompt.options[newY]) 
        end 
    end 

    if prompt and prompt.active then
        newY = newY or oldY
        newX = newX or oldX

        selectionPosition = {X = newX, Y = newY}
    end

    output:refresh()
end

--prompt helpers 
local function prompt(self, name, options, callback, maxSelection)
    if type(self)=="table" then
        error("prompt() must be called with \":\", not \".\"")
        return
    end


    maxSelection = maxSelection or 1

    if activeInputObject and activeInputObject.active then 
        closePrompt(activeInputObject)
        output.__local.setActiveInputObject(activeInputObject)
    end 

    if type(options)=="function" then
        callback = options
        options = nil
    end

    if not callback then return error("Must have callback") end


    if not options then 
        io.write(name .. "\nUser> ") 
        local userInp = io.read() 
        table.insert(output.messages, message.new(name .. "\nUser> " .. string.color(userInp or "(none)", "cyan")))
        callback(userInp) 

        output:refresh() 
        return userInp 
    end

    local newOptions = {}

    for Y, XOptions in ipairs(options) do
        newOptions[Y] = {}
        for X, option in ipairs(XOptions) do 
            newOptions[Y][X] = {
                name = tostring(option),
                value = option,
                __isSelected = false
            }
        end 
    end 

    if maxSelection > 1 then 
        newOptions[#newOptions+1] = {
            {
                name = string.color("[ SUBMIT > ]", config.submitButtonColor),
                value = nil,
                __isSelected = false,
                __identifyAsSubmit = true
            }
        }
    end 


    local inputObject = {
        name = name, 
        active = true, 
        options = newOptions, 
        callback = callback, 
        maxAllowedOptions = maxSelection 
    }

    activeInputObject = inputObject
    selectionPosition = {X=1,Y=1}
    output.__local.setActiveInputObject(activeInputObject)

    uv.tty_set_mode(stdin, 1)
    uv.read_start(stdin, function(err, data)
        if err then error(err) end 
        if data then 
            onNewInput(data)
        end 
    end) 

    output:refresh()

    return inputObject
end


--# Cleanup #--

output.__local.setGetOptionsStringFunction(getOptionsString)

return {
    prompt = prompt,
    closePrompt = closePrompt, 
    exit = exit
}