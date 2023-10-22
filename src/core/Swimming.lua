-- This code has been adapted from an old script
-- Original Author unknown
Swimming = {}
local SWIMMING_ANIMATION_2 = 0x300024D1
local WATER_ACTION_END = 0x300022C2
local WATER_IDLE = 0x380022C0

function Swimming.swim()
	if not Settings.swim then return end

	if Memory.current.mario_action == SWIMMING_ANIMATION_2
		or Memory.current.mario_action == WATER_ACTION_END
		or Memory.current.mario_action == WATER_IDLE then
		j = joypad.get(Settings.controller_index)
		j[Settings.swimming_button] = 1
		joypad.set(Settings.controller_index, j)
	end
end
