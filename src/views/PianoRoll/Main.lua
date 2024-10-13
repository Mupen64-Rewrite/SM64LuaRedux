---utility functions---

function GetGlobalTimer()
    return memory.readdword(Addresses[Settings.address_source_index].global_timer)
end

function CloneInto(destination, source)
    local anyChanges = false
    for k, v in pairs(source) do
        anyChanges = anyChanges or v ~= destination[k]
        destination[k] = v
    end
    return anyChanges
end

local SelectionGui = dofile(views_path .. "PianoRoll/SelectionGui.lua")
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")

emu.atupdatescreen(function()
    -- prevent reentrant calls caused by GUI actions while the game is running
    if PianoRollContext.current == nil or PianoRollContext.current then return end

    PianoRollContext.current:update()
end)

emu.atinput(function()
    local globalTimerValue = GetGlobalTimer()
    if PianoRollContext.current ~= nil and globalTimerValue > PianoRollContext.current.endGT then
        PianoRollContext.current.endGT = globalTimerValue
        PianoRollContext.current.previewGT = globalTimerValue
        PianoRollContext.current:edit(globalTimerValue)
    end
end)

---public API---

---Retrieves a TASState as determined by the currently active piano roll for the current frame identified by the current global timer value.
---
---If the current piano roll does not define what to do for this frame, or there is no current piano roll, nil is returned instead.
---
---@return table|nil override A table that can be assigned to TASState, additionally holding a field 'joy' that can be passed to joypad.set(...).
function CurrentPianoRollOverride()
    if (PianoRollContext.current == nil) then return nil end
    return PianoRollContext.current.frames[GetGlobalTimer()]
end

-- TODO: recording should also happen when the tab isn't "active", but I don't know how to do that right now
local function Record(input)
    for k,v in pairs(TASState) do
        input[k] = v
    end
    input.joy = {}
    for k,v in pairs(joypad.get(1)) do
        input.joy[k] = v

        if TASState.movement_mode == MovementModes.disabled then
            input.movement_mode = MovementModes.manual
            input.manual_joystick_x = Joypad.input.X
            input.manual_joystick_y = Joypad.input.Y
        end
    end
end

---@class PianoRollContext
---@field public current PianoRoll|nil The currently selected and active piano roll.
---@field public all table An array of up to 7 piano rolls to easily switch between for rapid iteration, indexed from 1 through 7 inclusively.
---@field public maxDisplayedFrames integer The maximum number of frames to display at once.
PianoRollContext = {
    current = nil,
    all = {},
    maxDisplayedFrames = 15,
    selection = nil,
    GetInput = function(globalTimer)
        PianoRollContext.current.startGT = math.min(GetGlobalTimer(), PianoRollContext.current.startGT)

        local input = PianoRollContext.current.frames[globalTimer];
        if (not input) then
            input = {}
            Record(input)
            PianoRollContext.current.frames[globalTimer] = input
            input.enable_engine = true
        end
        return input
    end,
}

return {
    name = "Piano Roll",
    draw = function()
        SelectionGui.Render()

        -- prevent reentrant calls caused by GUI actions while the game is running
        if PianoRollContext.current == nil or PianoRollContext.current.busy then return end
        if FrameListGui.Render() then
            PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
        end
    end,
}