-- This code has been adapted from an old script
-- Original Author unknown
local SWIMMING_ANIMATION_2 = 0x300024D1
local WATER_ACTION_END = 0x300022C2
local WATER_IDLE = 0x380022C0

return {
	process = function(input)
		if not TASState.swim then
			return input
		end

		if Memory.current.mario_action == SWIMMING_ANIMATION_2
			or Memory.current.mario_action == WATER_ACTION_END
			or Memory.current.mario_action == WATER_IDLE then
			input[Settings.swimming_button] = 1
		end
		return input
	end
}
