---@class PianoRoll
---@field public previewGT integer The global timer value to which to advance to when changes to the piano roll have been made.
---@field public startGT integer The global timer value indicating the inclusive start of this piano roll.
---@field public editingGT integer The global timer value indicating the frame of this piano roll that is currently being edited.
---@field public endGT integer The global timer value indicating the exclusive end of this piano roll.
---@field public frames table A table mapping from global timer values to the respective intended inputs and TASState.
---@field public name string A name for the piano roll for convenience.
local __clsPianoRoll = {}

---@return PianoRoll result Creates a new PianoRoll starting at the provided global timer value
---@param globalTimer integer TODO: This should always be the current global timer, there's no sense in trying to use this
function __clsPianoRoll.new(globalTimer)
    ---@type PianoRoll
    local newInstance = {
        busy = false,
        startGT = globalTimer,
        endGT = globalTimer,
        previewGT = globalTimer,
        editingGT = globalTimer,
        frames = {},
        name = "Default",
        _oldTASState = {},
        _oldClock = 0,
        _updatePending = false,
        numFrames = __clsPianoRoll.numFrames,
        edit = __clsPianoRoll.edit,
        update = __clsPianoRoll.update,
        jumpTo = __clsPianoRoll.jumpTo,
    }
    savestate.savefile("piano_roll_" .. globalTimer .. ".st")
    return newInstance
end

function __clsPianoRoll:numFrames() return self.endGT - self.startGT end

function __clsPianoRoll:edit(globalTimerTarget)
    self.editingGT = globalTimerTarget
    TASState = self.frames[globalTimerTarget] or TASState
    self._oldClock = os.clock()
end

function __clsPianoRoll:jumpTo(globalTimerTarget)
    self.previewGT = globalTimerTarget
    self.busy = true
    savestate.loadfile("piano_roll_" .. self.startGT .. ".st")
    emu.pause(true)
    local was_ff = emu.get_ff()
    emu.set_ff(true)
    local runUntilSelected
    runUntilSelected = function()
        if GetGlobalTimer() >= self.previewGT then
            emu.pause(false)
            emu.set_ff(was_ff)
            emu.atinput(runUntilSelected, true)
            self.busy = false
        end
    end
    emu.atinput(runUntilSelected)
end

function __clsPianoRoll:update()
    local anyChange = CloneInto(self._oldTASState, TASState)
    local now = os.clock()
    if anyChange then
        self._oldClock = now
        self._updatePending = true
    elseif self._updatePending and now - self._oldClock > 0.25 then
        self._oldClock = now
        self:jumpTo(self.previewGT)
        self._updatePending = false
    end
end

return {
    new = __clsPianoRoll.new
}