Program = {

}

function Program.initFrame()
	Memory.UpdatePrevPos()
	Memory.Refresh()
	Joypad.init()
end

function Program.rngSetter()
	if Settings.Layout.Button.SET_RNG == true then
		if Settings.setRNG then
			-- Write to the RNG value address
			if Settings.Layout.Button.set_rng_mode.value then
				memory.writeword(0x00B8EEE0, math.floor(Settings.setRNG))
			else
				memory.writeword(0x00B8EEE0, get_value(math.floor(Settings.setRNG)))
			end
			Settings.setRNG = false
			Settings.Layout.Button.SET_RNG = false
		end
	end
end

function Program.main()
	if Settings.Layout.Button.selectedItem ~= Settings.Layout.Button.DISABLED then
		result = Engine.inputsForAngle()
		if Settings.goalMag then
			Engine.scaleInputsForMagnitude(result, Settings.goalMag, Settings.Layout.Button.strain_button.highmag)
		end
		Joypad.set('X', result.X)
		Joypad.set('Y', result.Y)
	end
end
