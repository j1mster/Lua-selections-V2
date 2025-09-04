--# VS Code Tags #--

--# Variables #--

local output                = require("output")


--# Local Functions #--

local function update(self, newContent)
    self.content = newContent 
    output.refresh()
end
local function pin(self)
    self.pinned = true
end
local function unpin(self)
    self.pinned = false
end
local function delete(self)
    for index, message in pairs(output.messages) do 
        if message == self then 
            table.remove(output.messages, index)
        end
    end
end

local function newMessage(content) 
    local messageTable = {} 
    messageTable.content = content 
    messageTable.creationTime = os.clock()

    messageTable.update = update
    messageTable.pin = pin 
    messageTable.unpin = unpin
    messageTable.delete = delete

    table.insert(output.messages, messageTable)
end 


--# Finalization #--

_G.lua_selections.newMessage = newMessage

return {
    new = newMessage
}