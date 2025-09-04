--# VS Code Tags #--

---@diagnostic disable: inject-field


--# Variables #--

local colors                = {black=30,red=31,green=32,yellow=33,blue=34,magenta=35,cyan=36,white=37,pink=95,orange=91,brightBlue=94}


--# Local Functions #--

local function strip(str)
    return str:gsub('\27%[%d+;%d+m', ''):gsub('\27%[0m', '')
end
local function color(str, color)
    local cleanedString = strip(str)

    return string.format('\27[%i;%im%s\27[0m', 1, colors[color or "white"] or colors.white, cleanedString)
end


--# Finalization #--

string.strip = strip
string.color = color

return string 