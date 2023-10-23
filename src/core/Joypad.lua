Joypad = {
	input = {
		
	}
}

function Joypad.update()
	Joypad.input = joypad.get(Settings.controller_index)
end

function Joypad.send()
	joypad.set(Settings.controller_index, Joypad.input)
end

function Joypad.set(key, value)
	Joypad.input[key] = value
end