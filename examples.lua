local selections = require("init")

local output = selections.output
local str = selections.string

-- Chaotic ending
local function doomSequence()
    local msg = output:write("Nice choice, loser.")
    msg:pin() -- pinned forever
    output:write("You have unlocked the secret ending: Eternal Clown Mode.")
    repeat
        output:write(str.color("HONK HONK 🤡", "pink"))
        os.execute("start ./catmilk.webp") -- you need the file here
    until false
end

-- Offer redemption with recursion
local function offerRedemption(attempts)
    if attempts >= 3 then
        output:error("Alright that's it. You're officially banned from the cool kids club.")
        doomSequence()
    end

    selections.createPrompt("Last chance. Will you finally cooperate?", {
        {"no >:("},
        {"fine whatever"}
    }, function(choice)
        if not choice then return end
        if choice.value == "no >:(" then
            output:warn("bruh.")
            offerRedemption(attempts + 1)
        else
            output:write("Wow. Growth. Character development. Stunning.")
            output:write("You may proceed to the rest of the dumb adventure.")
        end
    end)
end

-- Start adventure
selections.createPrompt("yo what's your name?", function(name)
    output:write("cool. hi " .. name .. ".")

    selections.createPrompt("how many chicken nuggets could you eat in one sitting?", {
        {"4"}, {"10"}, {"20"}, {"69"}, {"none, I'm vegan"}
    }, function(nugCount)
        if not nugCount then return end
        if nugCount.value == "none, I'm vegan" then
            output:write("bro just say you’re better than me and move on.")
        elseif nugCount.value == "69" then
            output:write("nice.")
        else
            output:write("respectable. slightly disappointing, but respectable.")
        end

        -- Multi-select demo
        selections.createPrompt("choose your starter pack (pick 2):", {
            {"anxiety", "crushing debt"},
            {"cool jacket", "free trial of sadness"}
        }, function(starters)
            for pick in pairs(starters) do
                output:write("you chose: " .. pick)
            end

            selections.createPrompt("are you ready to face your destiny?", {
                {"yes"}, {"no"}, {"define 'ready'"}
            }, function(destiny)
                if not destiny then return end
                if destiny.value == "no" then
                    output:write("ok coward.")
                    offerRedemption(1)
                elseif destiny.value == "define 'ready'" then
                    output:write("google it.")
                    offerRedemption(1)
                else
                    output:write("let's roll.")
                end
            end)
        end, 2) -- allow up to 2
    end)
end)
