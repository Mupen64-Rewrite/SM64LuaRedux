Program = {

}

function Program.new_frame()
	Memory.UpdatePrevPos()
	Memory.Refresh()
	Joypad.init()
end

function Program.rngSetter()
	if Settings.override_rng then
		-- Write to the RNG value address
		if Settings.override_rng_use_index then
			memory.writeword(0x00B8EEE0, get_value(math.floor(Settings.override_rng_value)))
		else
			memory.writeword(0x00B8EEE0, math.floor(Settings.override_rng_value))
		end
	end
end

function Program.main()
	if Settings.movement_mode ~= Settings.movement_modes.disabled then
		result = Engine.inputsForAngle()
		if Settings.goal_mag then
			Engine.scaleInputsForMagnitude(result, Settings.goal_mag, Settings.high_magnitude)
		end
		Joypad.set('X', result.X)
		Joypad.set('Y', result.Y)
	end
end
