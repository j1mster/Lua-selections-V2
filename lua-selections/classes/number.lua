--# VS Code Tags #--

--# Variables #--

--# Local Functions #--

local function clamp(x, min, max)
    return (x>max and max) or (x<min and min) or x
end
local function countTable(t) 
    local total = 0
    for _ in pairs(t) do 
        total = total + 1
    end 
    return total
end 


--# Finalization #--

return {
    clamp = clamp,
    countTable = countTable
}