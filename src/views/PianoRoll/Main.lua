---utility functions---

function GetGlobalTimer()
    return memory.readdword(Addresses[Settings.address_source_index].global_timer)
end

function CloneInto(destination, source)
    local changes = {}
    for k, v in pairs(source) do
        if v ~= destination[k] then changes[k] = v end
        anyChanges = anyChanges or v ~= destination[k]
        destination[k] = v
    end
    return changes
end

local function Record(input)
    for k,v in pairs(TASState) do
        input[k] = v
    end
    input.joy = {}
    for k,v in pairs(joypad.get(1)) do
        input.joy[k] = v
    end
    for k,v in pairs(TASState) do
        input[k] = v
    end

    if TASState.movement_mode == MovementModes.disabled then
        input.movement_mode = MovementModes.manual
        input.manual_joystick_x = Joypad.input.X
        input.manual_joystick_y = Joypad.input.Y
    end
end

local SelectionGui = dofile(views_path .. "PianoRoll/SelectionGui.lua")
local FrameListGui = dofile(views_path .. "PianoRoll/FrameListGui.lua")
local JoystickGui = dofile(views_path .. "PianoRoll/JoystickGui.lua")

emu.atupdatescreen(function()
    -- prevent reentrant calls caused by GUI actions while the game is running
    if PianoRollContext.current == nil or PianoRollContext.current then return end

    PianoRollContext.current:update()
end)

---public API---

---Retrieves a TASState as determined by the currently active piano roll for the current frame identified by the current global timer value.
---
---If the current piano roll does not define what to do for this frame, or there is no current piano roll, nil is returned instead.
---
---@return table|nil override A table that can be assigned to TASState, additionally holding a field 'joy' that can be passed to joypad.set(...).
function CurrentPianoRollOverride()
    if (PianoRollContext.current == nil) then return nil end
    local globalTimer = GetGlobalTimer()
    if PianoRollContext.current ~= nil and globalTimer >= PianoRollContext.current.endGT then
        local input = {}
        Record(input)
        PianoRollContext.current.endGT = globalTimer + 1
        PianoRollContext.current.previewGT = globalTimer
        PianoRollContext.current.editingGT = globalTimer
        PianoRollContext.current.frames[globalTimer] = input
    end

    return PianoRollContext.current.frames[globalTimer]
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
}

return {
    name = "Piano Roll",
    draw = function()
        SelectionGui.Render()

        -- prevent reentrant calls caused by GUI actions while the game is running
        if PianoRollContext.current == nil or PianoRollContext.current.busy then return end
        if FrameListGui.Render() or JoystickGui.Render() then
            PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
        end
    end,
}