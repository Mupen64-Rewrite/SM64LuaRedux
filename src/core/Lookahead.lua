Lookahead = {}

local counter = 0

local function save()
    if savestate.saveslot then
        savestate.saveslot(9)
    else
        savestate.savefile("lookahead.st")
    end
end

local function load()
    if savestate.loadslot then
        savestate.loadslot(9)
    else
        savestate.loadfile("lookahead.st")
    end
end

Lookahead.update = function()
    if not Settings.lookahead then
        return
    end

    counter = counter + 1

    if counter >= Settings.lookahead_length then
        counter = 0
        load()
    end
end

Lookahead.start = function()
    counter = 0
    emu.pause(true)
    save()
end
